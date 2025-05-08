use crate::{context::Context, event_filter::EventFilter};
use anyhow::Result;
use axum::{extract::Query, response::Json, Extension};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::vec;

#[derive(Default, Serialize, Deserialize)]
pub struct Event {
    pub title: Option<String>,
    pub start: Option<DateTime<Utc>>,
    pub end: Option<DateTime<Utc>>,
    pub description: Option<String>,
}

async fn fetch(context: Context, filter: EventFilter) -> Result<Vec<Event>> {
    let response = reqwest::Client::new()
        .get(context.config().calendar_url())
        .query(&[
            ("singleEvents", "true"),
            ("key", context.config().api_key()),
            ("timeMin", &filter.time_min.to_rfc3339()),
            ("timeMax", &filter.time_max.to_rfc3339()),
        ])
        .send()
        .await?;

    let events = response.json::<serde_json::Value>().await?;

    let mut result = Vec::new();

    for item in events["items"].as_array().unwrap_or(&vec![]) {
        let event = Event {
            title: item["summary"].as_str().map(|s| s.to_string()),
            start: item["start"]["dateTime"]
                .as_str()
                .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
                .map(|dt| dt.with_timezone(&Utc)),
            end: item["end"]["dateTime"]
                .as_str()
                .and_then(|s| DateTime::parse_from_rfc3339(s).ok())
                .map(|dt| dt.with_timezone(&Utc)),
            description: item["description"].as_str().map(|s| s.to_string()),
        };
        result.push(event);
    }

    Ok(result)
}

pub async fn handler(
    Extension(context): Extension<Context>,
    Query(filter): Query<EventFilter>,
) -> Json<Vec<Event>> {
    Json(fetch(context, filter).await.unwrap_or_default())
}
