use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct Pagination {
    pub page: Option<u32>,
    pub page_size: Option<u32>,
    pub id: Option<u32>,
}

#[derive(Serialize)]
pub struct PaginatedResponse<T> {
    pub data: T,
    pub page: u32,
    pub page_size: u32,
    pub total: u32,
}
