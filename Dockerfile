# المرحلة 1: بيئة التحميل المستقرة
FROM debian:bullseye-slim AS builder

# تثبيت أدوات الشبكة والشهادات الأمنية لضمان الاتصال بالمصدر
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# الرابط المدقق والمباشر لنسخة مارس 2026
# نستخدم --no-check-certificate فقط إذا واجه السيرفر مشكلة في تحديث الشهادات
RUN wget -q https://nubit.sh/nubit-bin/nubit-node-linux-amd64.tar.gz && \
    tar -xvf nubit-node-linux-amd64.tar.gz --strip-components=1 && \
    rm nubit-node-linux-amd64.tar.gz

# المرحلة 2: الإنتاج (Production) - أصغر حجم ممكن لضمان عدم الحظر
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /nubit

# نقل الملفات التنفيذية فقط
COPY --from=builder /app/nubit .
COPY --from=builder /app/nkey .

# منح الصلاحيات الاحترافية
RUN chmod +x nubit nkey

# إعدادات الشبكة (نظام الطبقات)
ENV NUBIT_NETWORK=nubit-alphatestnet-1

# تشغيل النود مع ميزة التنبيه الذكي
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
