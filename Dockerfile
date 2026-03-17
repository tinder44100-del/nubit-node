# المرحلة الأولى: البناء من المصدر
FROM rust:1.75-bullseye AS builder
RUN apt-get update && apt-get install -y clang cmake build-essential git
WORKDIR /app
RUN git clone https://github.com/0glabs/0g-storage-node.git . \
    && cargo build --release

# المرحلة الثانية: التشغيل الصافي (الإنتاج)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نقل الملف التنفيذي فقط
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/zgs_node

# إعدادات المسارات
ENV NETWORK_ID="zgs_testnet_8888"

# سكريبت المراقبة الذكي لإعادة التشغيل تلقائياً
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
