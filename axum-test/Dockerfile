FROM ekidd/rust-musl-builder:stable as builder
WORKDIR /home/rust
COPY . .
RUN cargo build --release

FROM alpine:latest
WORKDIR /my_app
COPY --from=builder /home/rust/target/x86_64-unknown-linux-musl/release/axum-test .
EXPOSE 8080
ENTRYPOINT [ "./axum-test" ]
