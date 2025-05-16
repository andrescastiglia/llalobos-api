use std::{env, sync::Arc};

pub type Config = Arc<ConfigInner>;

pub struct ConfigInner {
    postgres_url: String,
    postgres_max_connections: u32,
    listener: String,
    calendar_url: String,
    calendar_main: String,
    calendar_election: String,
    api_key: String,
}

impl Default for ConfigInner {
    fn default() -> Self {
        Self {
            postgres_url: env::var("POSTGRES_URL").expect("POSTGRES_URL is missing"),
            postgres_max_connections: env::var("POSTGRES_MAX_CONNECTIONS")
                .expect("POSTGRES_MAX_CONNECTIONS is missing")
                .parse()
                .expect("POSTGRES_MAX_CONNECTIONS is not a number"),
            listener: env::var("LISTENER").expect("LISTENER is missing"),
            calendar_url: env::var("CALENDAR_URL").expect("CALENDAR_URL is missing"),
            calendar_main: env::var("CALENDAR_MAIN").expect("CALENDAR_MAIN is missing"),
            calendar_election: env::var("CALENDAR_ELECTION").expect("CALENDAR_ELECTION is missing"),
            api_key: env::var("API_KEY").expect("API_KEY is missing"),
        }
    }
}

impl ConfigInner {
    pub fn postgres_url(&self) -> &str {
        &self.postgres_url
    }

    pub fn postgres_max_connections(&self) -> u32 {
        self.postgres_max_connections
    }

    pub fn listener(&self) -> &str {
        &self.listener
    }

    pub fn calendar_url(&self) -> &str {
        &self.calendar_url
    }

    pub fn calendar_main(&self) -> &str {
        &self.calendar_main
    }

    pub fn calendar_election(&self) -> &str {
        &self.calendar_election
    }

    pub fn api_key(&self) -> &str {
        &self.api_key
    }
}
