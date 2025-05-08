use chrono::{DateTime, Utc};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct EventFilter {
    pub time_min: DateTime<Utc>,
    pub time_max: DateTime<Utc>,
}
