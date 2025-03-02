use std::env;

pub struct Config {
    postgres_url: String,
    postgres_max_connections: u32,
    listener: String,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            postgres_url: env::var("POSTGRES_URL").expect("POSTGRES_URL is missing"),
            postgres_max_connections: env::var("POSTGRES_MAX_CONNECTIONS")
                .expect("POSTGRES_MAX_CONNECTIONS is missing")
                .parse()
                .expect("POSTGRES_MAX_CONNECTIONS is not a number"),
            listener: env::var("LISTENER").expect("LISTENER is missing"),
        }
    }
}

impl Config {
    pub fn postgres_url(&self) -> &str {
        &self.postgres_url
    }

    pub fn postgres_max_connections(&self) -> u32 {
        self.postgres_max_connections
    }

    pub fn listener(&self) -> &str {
        &self.listener
    }
}
