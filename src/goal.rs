use axum::{extract::Extension, response::Json};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

#[derive(Default, Serialize, Deserialize)]
pub struct Goal {
    pub balance: Option<Decimal>,
    pub target: Option<Decimal>,
}

async fn fetch(pool: &PgPool) -> Result<Goal, sqlx::Error> {
    let goal = sqlx::query_as!(Goal, "SELECT balance, target FROM goal")
        .fetch_one(pool)
        .await?;

    Ok(goal)
}

pub async fn handler(Extension(pool): Extension<sqlx::PgPool>) -> Json<Goal> {
    Json(fetch(&pool).await.unwrap_or_default())
}
