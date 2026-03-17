# المرحلة الأولى: التحميل والبناء
FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y curl tar ca-certificates

WORKDIR /download

# تحميل الملف مع إضافة محاولات إعادة الاتصال في حال الانقطاع
RUN curl -L --retry 5 --retry-delay 2 https://nubit.sh/nubit-bin/nubit-node-linux-amd64.tar.gz -o nubit.tar.gz \
    && tar -xzf nubit.tar.gz --strip-components=1

# المرحلة الثانية: بيئة التشغيل الخفيفة
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# نسخ الملفات التنفيذية فقط من المرحلة الأولى
COPY --from=builder /download/nubit .
COPY --from=builder /download/nkey .

# منح صلاحيات التنفيذ
RUN chmod +x nubit nkey

# إعداد المتغيرات
ENV NUBIT_NETWORK=nubit-alphatestnet-1

# تشغيل النود
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
