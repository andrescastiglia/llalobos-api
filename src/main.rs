mod params;
mod shutdown;
mod transaction;

use axum::{extract::Extension, routing::get, Router};
use sqlx::postgres::PgPoolOptions;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = params::Config::default();

    let pool = PgPoolOptions::new()
        .max_connections(config.postgres_max_connections())
        .connect(config.postgres_url())
        .await
        .expect("Error connecting to the database");

    let app = Router::new()
        .route("/transactions", get(transaction::handler))
        .layer(Extension(pool));

    let listener = tokio::net::TcpListener::bind(config.listener())
        .await
        .expect("Failed to parse local address to listen");

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown::signal())
        .await
        .expect("Failed to bind server to address");
}
