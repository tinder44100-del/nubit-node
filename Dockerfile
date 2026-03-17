# المرحلة 1: بناء النود مع كافة التبعيات التقنية لعام 2026
FROM rust:1.75-bullseye AS builder

# تثبيت الأدوات الهندسية المفقودة والمطلوبة لعملية الـ Compiling
RUN apt-get update && apt-get install -y \
    clang cmake build-essential git protobuf-compiler libssl-dev pkg-config

WORKDIR /app
# سحب الكود المصدري الرسمي
RUN git clone https://github.com/0glabs/0g-storage-node.git .

# تنفيذ البناء النهائي للنسخة المستقرة
RUN cargo build --release

# المرحلة 2: بيئة التشغيل الصافية والموفرة للموارد
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نقل الملف التنفيذي zgs_node فقط لتقليل حجم الحاوية في Railway
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# سكريبت الاستمرارية الذكي لإعادة التشغيل الآلي
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
