use crate::{context::Context, event_filter::EventFilter};
use anyhow::Result;
use axum::{extract::Query, response::Json, Extension};
use chrono::{DateTime, Duration, NaiveDate, NaiveTime, TimeZone, Utc};
use chrono_tz::America::Argentina::Buenos_Aires;
use serde::{Deserialize, Serialize};
use std::vec;

#[derive(Default, Serialize, Deserialize)]
pub struct Event {
    pub title: Option<String>,
    pub start: Option<DateTime<Utc>>,
    pub end: Option<DateTime<Utc>>,
    pub description: Option<String>,
    pub calendar: CalendarType,
}

#[derive(Serialize, Deserialize, Clone)]
pub enum CalendarType {
    #[serde(rename = "Principal")]
    Main,
    #[serde(rename = "Elecciones")]
    Election,
}

impl Default for CalendarType {
    fn default() -> Self {
        CalendarType::Main
    }
}

fn parse(dt: Option<&str>, d: Option<&str>, start: bool) -> Option<DateTime<Utc>> {
    if let Some(dt) = dt {
        if let Ok(dt) = DateTime::parse_from_rfc3339(dt) {
            return Some(dt.with_timezone(&Utc));
        }
    }
    if let Some(d) = d {
        if let Ok(date) = NaiveDate::parse_from_str(d, "%Y-%m-%d") {
            let midnight = NaiveTime::from_hms_opt(0, 0, 0)?;
            let dt = if start {
                date.and_time(midnight)
            } else {
                date.and_time(midnight) - Duration::seconds(1)
            };
            return match Buenos_Aires.from_local_datetime(&dt) {
                chrono::LocalResult::Single(datetime) => Some(datetime.with_timezone(&Utc)),
                _ => None,
            };
        }
    }
    None
}

async fn fetch(context: Context, filter: EventFilter) -> Result<Vec<Event>> {
    let mut result = Vec::new();

    let calendars = vec![
        (CalendarType::Main, context.config().calendar_main()),
        (CalendarType::Election, context.config().calendar_election()),
    ];

    for (calendar_type, calendar_id) in calendars {
        let calendar_url = format!("{}/{}/events", context.config().calendar_url(), calendar_id);

        let response = reqwest::Client::new()
            .get(calendar_url)
            .query(&[
                ("singleEvents", "true"),
                ("key", context.config().api_key()),
                ("timeMin", &filter.time_min.to_rfc3339()),
                ("timeMax", &filter.time_max.to_rfc3339()),
            ])
            .send()
            .await?;

        let events = response.json::<serde_json::Value>().await?;

        for item in events["items"].as_array().unwrap_or(&vec![]) {
            let event = Event {
                title: item["summary"].as_str().map(|s| s.to_string()),
                start: parse(
                    item["start"]["dateTime"].as_str(),
                    item["start"]["date"].as_str(),
                    true,
                ),
                end: parse(
                    item["end"]["dateTime"].as_str(),
                    item["end"]["date"].as_str(),
                    false,
                ),
                description: item["description"].as_str().map(|s| s.to_string()),
                calendar: calendar_type.clone(),
            };
            result.push(event);
        }
    }

    Ok(result)
}

pub async fn handler(
    Extension(context): Extension<Context>,
    Query(filter): Query<EventFilter>,
) -> Json<Vec<Event>> {
    Json(fetch(context, filter).await.unwrap_or_default())
}
