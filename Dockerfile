# المرحلة الأولى: البناء مع كافة الأدوات اللازمة
FROM rust:1.75-bullseye AS builder

# تثبيت الأدوات الهندسية المطلوبة بما فيها المترجم المفقود protoc
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    build-essential \
    git \
    protobuf-compiler \
    libssl-dev \
    pkg-config

WORKDIR /app

# سحب الكود المصدري لنود 0G Labs
RUN git clone https://github.com/0glabs/0g-storage-node.git .

# تشغيل البناء النهائي (هذه المرة سينجح لوجود المترجم)
RUN cargo build --release

# المرحلة الثانية: التشغيل النهائي (لتصغير حجم الحاوية)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نقل الملف التنفيذي فقط
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# إضافة سكريبت الاستمرارية لضمان عدم توقف النود
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
