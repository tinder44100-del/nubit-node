# المرحلة الأولى: البناء مع كافة الأدوات اللازمة
FROM rust:1.75-bullseye AS builder

# تثبيت الأدوات الهندسية المطلوبة بما فيها المترجم المفقود protoc والمكتبات الأمنية
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

# تشغيل البناء النهائي (هذه المرة سينجح لوجود المترجم المذكور في الخطأ)
RUN cargo build --release

# المرحلة الثانية: التشغيل النهائي (لتصغير حجم الحاوية وتوفير موارد السيرفر)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نقل الملف التنفيذي فقط من مرحلة البناء
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# إضافة سكريبت الاستمرارية لضمان إعادة التشغيل التلقائي في حال تعثرت النود
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
