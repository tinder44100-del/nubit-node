# المرحلة 1: بناء النود مع كافة التبعيات التقنية
FROM golang:1.21-bullseye AS builder

# تثبيت الأدوات الهندسية المفقودة (التي تسببت في الخطأ السابق)
RUN apt-get update && apt-get install -y \
    clang cmake build-essential git protobuf-compiler libssl-dev pkg-config

# إعداد بيئة Rust (اللازمة لبناء 0g-storage-node)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
RUN git clone https://github.com/0glabs/0g-storage-node.git .

# تشغيل البناء النهائي (هنا سيتم تجاوز الخطأ السابق)
RUN cargo build --release

# المرحلة 2: بيئة التشغيل المصغرة (Lightweight Runtime)
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /root/

# نقل الملف التنفيذي الناتج
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/

# سكريبت الاستمرارية لضمان العوائد وعدم التوقف
RUN echo '#!/bin/bash\n\
while true; do\n\
  /usr/local/bin/zgs_node --config /root/config.toml\n\
  echo "Node crashed, restarting in 5 seconds..."\n\
  sleep 5\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
