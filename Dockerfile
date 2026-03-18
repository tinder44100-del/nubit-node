# المرحلة الأولى: بناء التطبيق (Build Stage)
# استخدام نسخة Bookworm للحصول على أحدث إصدارات مكتبات C و Protoc
FROM rust:1.75-bookworm AS builder

# تحديث وتثبيت التبعيات الهندسية المعتمدة مع تنظيف الذاكرة المؤقتة (Best Practice)
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    build-essential \
    git \
    protobuf-compiler \
    libprotobuf-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# تأكيد مسار المترجم صراحة لتجنب ضياع مسارات البيئة
ENV PROTOC=/usr/bin/protoc

# --- حماية الذاكرة العشوائية (RAM) ---
# تقليل عدد مسارات البناء لتجنب توقف الخوادم السحابية بسبب استهلاك الذاكرة (OOM Kill)
ENV CARGO_BUILD_JOBS=2

WORKDIR /app

# استنساخ المشروع مع التبعيات الفرعية (Submodules) لضمان عدم نقص أي مكونات
RUN git clone --recursive https://github.com/0glabs/0g-storage-node.git .

# بناء المشروع النهائي
RUN cargo build --release

# المرحلة الثانية: التشغيل (Runtime Stage)
# استخدام النسخة الخفيفة المطابقة لبيئة البناء
FROM debian:bookworm-slim

# تثبيت التبعيات الأساسية لتشغيل العقدة (بما في ذلك tzdata لضبط توقيت السجلات بدقة)
RUN apt-get update && apt-get install -y ca-certificates curl jq tzdata && rm -rf /var/lib/apt/lists/*

WORKDIR /root/

# إنشاء المجلدات الضرورية لتخزين قاعدة البيانات
RUN mkdir -p /root/db

# نسخ الملفات من مرحلة البناء
COPY --from=builder /app/target/release/zgs_node /usr/local/bin/
COPY config.toml /root/config.toml

# سكريبت التشغيل الذكي (Watchdog) لإعادة التشغيل التلقائي مع تحسين تسجيل الأحداث
RUN echo '#!/bin/bash\n\
while true; do\n\
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] --- Starting 0G Node Service ---"\n\
  /usr/local/bin/zgs_node --config /root/config.toml 2>&1 | tee -a /root/node.log\n\
  EXIT_CODE=$?\n\
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Critical: Node crashed with exit code $EXIT_CODE. Restarting in 10s..."\n\
  sleep 10\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

# المنافذ حسب إعداداتك لعام 2026
EXPOSE 1234 5678

ENTRYPOINT ["/root/entrypoint.sh"]
