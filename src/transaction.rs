use crate::{
    context::Context,
    pagination::{PaginatedResponse, Pagination},
};
use axum::{
    extract::{Extension, Query},
    response::Json,
};
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Transaction {
    pub transaction_date: Option<DateTime<Utc>>,
    pub source_id: String,
    pub payer_name: Option<String>,
    pub transaction_amount: Option<Decimal>,
    pub transaction_type: Option<String>,
}

async fn count(context: &Context) -> Result<i64, sqlx::Error> {
    let count = sqlx::query_scalar!("SELECT COUNT(*) FROM transactions")
        .fetch_one(context.pool())
        .await?;

    Ok(count.unwrap_or_default())
}

async fn fetch(
    context: &Context,
    page: u32,
    page_size: u32,
) -> Result<Vec<Transaction>, sqlx::Error> {
    let offset = (page - 1) * page_size;

    let transactions = sqlx::query_as!(
        Transaction,
        r#"
            SELECT transaction_date, source_id, trim(payer_name) as payer_name, transaction_amount, trim(transaction_type) as transaction_type
            FROM transactions
            ORDER BY transaction_date DESC
            LIMIT $1
            OFFSET $2
        "#,
        page_size as i64,
        offset as i64,
    )
    .fetch_all(context.pool())
    .await?;

    Ok(transactions)
}

pub async fn handler(
    Extension(context): Extension<Context>,
    Query(pagination): Query<Pagination>,
) -> Json<PaginatedResponse<Vec<Transaction>>> {
    let page = pagination.page.unwrap_or(1);
    let page_size = pagination.page_size.unwrap_or(10);

    let total = count(&context).await.unwrap_or_default();
    let transactions = fetch(&context, page, page_size).await.unwrap_or_default();

    Json(PaginatedResponse {
        data: transactions,
        page,
        page_size,
        total: total as u32,
    })
}
