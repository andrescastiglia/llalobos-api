use axum::{extract::Extension, response::Json};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

#[derive(Default, Serialize, Deserialize)]
pub struct Funds {
    pub name: Option<String>,
    pub value: Option<Decimal>,
}

async fn fetch(pool: &PgPool) -> Result<Vec<Funds>, sqlx::Error> {
    let funds = sqlx::query_as!(Funds, "SELECT payer_name as name, amount as value FROM funds LIMIT 10")
        .fetch_all(pool)
        .await?;

    Ok(funds)
}

pub async fn handler(Extension(pool): Extension<sqlx::PgPool>) -> Json<Vec<Funds>> {
    Json(fetch(&pool).await.unwrap_or_default())
}
