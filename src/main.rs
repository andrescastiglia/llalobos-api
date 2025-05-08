mod agenda;
mod config;
mod context;
mod event_filter;
mod funds;
mod goal;
mod news;
mod pagination;
mod shutdown;
mod transaction;

use axum::{extract::Extension, routing::get, Router};
use context::{Context, ContextBuilder};
use sqlx::postgres::PgPoolOptions;
use tracing_subscriber::EnvFilter;

#[tokio::main(worker_threads = 4)]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = config::Config::default();

    let pool = PgPoolOptions::new()
        .max_connections(config.postgres_max_connections())
        .connect(config.postgres_url())
        .await
        .expect("Error connecting to the database");

    let context = Context::build(pool, config.clone());

    let app = Router::new()
        .route("/agenda", get(agenda::handler))
        .route("/transactions", get(transaction::handler))
        .route("/goal", get(goal::handler))
        .route("/funds", get(funds::handler))
        .route("/news", get(news::handler))
        .layer(Extension(context));

    let listener = tokio::net::TcpListener::bind(config.listener())
        .await
        .expect("Failed to parse local address to listen");

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown::signal())
        .await
        .expect("Failed to bind server to address");
}
