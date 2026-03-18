# المرحلة الأولى: بناء التطبيق (Builder)
FROM rust:1.75-bullseye AS builder

# تثبيت الأدوات الهندسية والمترجم المفقود protoc
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    build-essential \
    git \
    protobuf-compiler \
    libssl-dev \
    pkg-config

WORKDIR /app

# جلب الكود المصدري
RUN git clone https://github.com/0glabs/0g-storage-node.git .

# بناء المشروع بالنمط النهائي
RUN cargo build --release

# المرحلة الثانية: بيئة التشغيل (Runtime) لتقليل الحجم وتوفير الموارد
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نسخ الملف التنفيذي فقط من مرحلة البناء
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# سكريبت التشغيل الذكي: يعيد تشغيل النود تلقائياً إذا توقفت
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
