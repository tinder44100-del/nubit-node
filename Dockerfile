# المرحلة الأولى: بناء التبعيات (Build Stage)
FROM rust:1.75-bullseye AS builder

# تثبيت الأدوات الضرورية وحل مشكلة protoc المفقودة
RUN apt-get update && apt-get install -y \
    clang cmake build-essential git protobuf-compiler libssl-dev pkg-config

WORKDIR /app

# استنساخ الكود المصدري الرسمي لـ 0G Labs
RUN git clone https://github.com/0glabs/0g-storage-node.git .

# بناء الملف التنفيذي بالنمط النهائي (Release)
RUN cargo build --release

# المرحلة الثانية: بيئة التشغيل الخفيفة (Runtime Stage)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# إنشاء مجلد البيانات لضمان المزامنة
RUN mkdir -p /root/db

# نقل الملف التنفيذي وملف الإعدادات
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/
COPY config.toml /root/config.toml

# سكريبت التشغيل الذكي (Watchdog) لإعادة التشغيل التلقائي
RUN echo '#!/bin/bash\n\
while true; do\n\
  echo "[$(date)] --- Launching 0G Storage Node ---"\n\
  /usr/local/bin/zgs_node --config /root/config.toml 2>&1 | tee -a /root/node.log\n\
  EXIT_CODE=$?\n\
  echo "[$(date)] Node exited with code $EXIT_CODE. Restarting in 5s..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

# فتح المنافذ المحددة في ملف Config الخاص بك
EXPOSE 1234 5678

ENTRYPOINT ["/root/entrypoint.sh"]
