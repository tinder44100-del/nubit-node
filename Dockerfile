# المرحلة 1: البناء السريع باستخدام Rust
FROM rust:1.75-bullseye AS builder
RUN apt-get update && apt-get install -y clang cmake build-essential git
WORKDIR /app
# سحب المستودع الرسمي لـ 0G Storage
RUN git clone https://github.com/0glabs/0g-storage-node.git . \
    && cargo build --release

# المرحلة 2: التشغيل الصافي (Production)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
WORKDIR /root/
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/zgs_node

# إعدادات الأداء الفائق: ربط النود بـ RPC سريع جداً (Public Endpoint)
ENV RPC_ENDPOINT=https://0g-json-rpc-public.0glabs.ai

# أمر التشغيل مع تحسين تدفق البيانات
CMD ["zgs_node", "--config", "config.toml"]
