use axum::{
    http::StatusCode,
    response::IntoResponse,
    routing::{get},
    Json, Router
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use chrono::prelude::*;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/", get(root));
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::info!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn root(axum::extract::Query(params): axum::extract::Query<TestRequest>) -> impl IntoResponse {
    let current_time = Utc::now().with_timezone(&FixedOffset::east(params.timezone));
    let resp = DateResponse {
        city: params.city.clone(),
        date: current_time.format("%Y/%m/%d").to_string(),
        time: current_time.format("%T").to_string(),
        day_of_week: format!("{}", current_time.date().weekday())
    };
    tracing::info!("req: {:?}, respnse: {:?}", params, resp);
    (StatusCode::OK, Json(resp))
}

#[derive(Deserialize, Debug)]
struct TestRequest {
    city: String,
    timezone: i32,
}

#[derive(Serialize, Deserialize, Debug)]
struct DateResponse {
    city: String,
    date: String,
    time: String,
    day_of_week: String,
}
