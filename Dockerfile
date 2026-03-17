# المرحلة الأولى: بناء احترافي من المصدر لتقليل حجم الحاوية
FROM golang:1.21-bullseye AS builder
RUN apt-get update && apt-get install -y git make gcc g++
WORKDIR /app
RUN git clone https://github.com/0glabs/0g-storage-node.git .
# بناء النسخة المستقرة لعام 2026
RUN make build

# المرحلة الثانية: بيئة التشغيل المعزولة (Lightweight)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# إعدادات تحسين الأداء (Speed Optimization)
ENV DB_PATH="/root/db"
ENV NETWORK_ID="zgs_testnet_8888"

# سكريبت التشغيل الذكي لضمان الاستمرارية
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
