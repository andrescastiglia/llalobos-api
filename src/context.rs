use crate::config::Config;
use std::sync::Arc;

pub type Context = Arc<ContextInner>;

pub trait ContextBuilder {
    fn build(pool: sqlx::PgPool, config: Config) -> Context;
}

impl ContextBuilder for Context {
    fn build(pool: sqlx::PgPool, config: Config) -> Context {
        ContextInner::new(pool, config)
    }
}

pub struct ContextInner {
    pub pool: sqlx::PgPool,
    pub config: Config,
}

impl ContextInner {
    pub fn new(pool: sqlx::PgPool, config: Config) -> Context {
        Arc::new(Self { pool, config })
    }

    pub fn pool(&self) -> &sqlx::PgPool {
        &self.pool
    }

    pub fn config(&self) -> &Config {
        &self.config
    }
}
