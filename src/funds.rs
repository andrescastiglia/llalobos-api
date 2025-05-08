use crate::context::Context;
use axum::{extract::Extension, response::Json};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize)]
pub struct Funds {
    pub name: Option<String>,
    pub value: Option<Decimal>,
}

async fn fetch(context: Context) -> Result<Vec<Funds>, sqlx::Error> {
    let funds = sqlx::query_as!(
        Funds,
        "SELECT payer_name as name, amount as value FROM funds LIMIT 10"
    )
    .fetch_all(context.pool())
    .await?;

    Ok(funds)
}

pub async fn handler(Extension(context): Extension<Context>) -> Json<Vec<Funds>> {
    Json(fetch(context).await.unwrap_or_default())
}
