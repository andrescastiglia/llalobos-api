use crate::context::Context;
use axum::{extract::Extension, response::Json};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize)]
pub struct Goal {
    pub balance: Option<Decimal>,
    pub target: Option<Decimal>,
}

async fn fetch(context: Context) -> Result<Goal, sqlx::Error> {
    let goal = sqlx::query_as!(Goal, "SELECT balance, target FROM goal")
        .fetch_one(context.pool())
        .await?;

    Ok(goal)
}

pub async fn handler(Extension(context): Extension<Context>) -> Json<Goal> {
    Json(fetch(context).await.unwrap_or_default())
}
