use crate::{
    context::Context,
    pagination::{PaginatedResponse, Pagination},
};
use axum::{
    extract::{Extension, Query},
    response::Json,
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize)]
pub struct News {
    pub id: i32,
    pub date: Option<DateTime<Utc>>,
    pub title: Option<String>,
    pub content: Option<String>,
    pub has_media: Option<bool>,
    pub media: Option<Vec<u8>>,
    pub transcription: Option<String>,
}

async fn count(context: &Context) -> Result<i64, sqlx::Error> {
    let count = sqlx::query_scalar!("SELECT COUNT(*) FROM news")
        .fetch_one(context.pool())
        .await?;

    Ok(count.unwrap_or_default())
}

async fn fetch_one(context: &Context, id: u32) -> Result<Vec<News>, sqlx::Error> {
    let news = sqlx::query_as!(
        News,
        r#"
            SELECT id, date, title, content, media is not null as has_media, media, transcription 
            FROM news 
            WHERE id = $1
        "#,
        id as i32
    )
    .fetch_all(context.pool())
    .await?;

    Ok(news)
}

async fn fetch_all(context: &Context, page: u32, page_size: u32) -> Result<Vec<News>, sqlx::Error> {
    let offset = (page - 1) * page_size;

    let news = sqlx::query_as!(News,
        r#"
            SELECT id, date, title, content, media is not null as has_media, ''::bytea as media, null as transcription 
            FROM news 
            ORDER BY date DESC
            LIMIT $1
            OFFSET $2
        "#,
        page_size as i64,
        offset as i64
    )
    .fetch_all(context.pool())
    .await?;

    Ok(news)
}

pub async fn handler(
    Extension(context): Extension<Context>,
    Query(pagination): Query<Pagination>,
) -> Json<PaginatedResponse<Vec<News>>> {
    let page = pagination.page.unwrap_or(1);
    let page_size = pagination.page_size.unwrap_or(10);

    let total = count(&context).await.unwrap_or_default();

    let news = if let Some(id) = pagination.id {
        fetch_one(&context, id).await.unwrap_or_default()
    } else {
        fetch_all(&context, page, page_size)
            .await
            .unwrap_or_default()
    };

    Json(PaginatedResponse {
        data: news,
        page,
        page_size,
        total: total as u32,
    })
}
