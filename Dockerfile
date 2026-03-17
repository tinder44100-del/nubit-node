# استخدام نسخة مستقرة وخفيفة
FROM debian:bullseye-slim

# تنظيف وتثبيت الأدوات الضرورية في طبقة واحدة لتقليل حجم الصورة
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مسار العمل
WORKDIR /nubit

# سحب ملف النود الرسمي (الرابط المباشر للأداء العالي)
RUN curl -sL https://nubit.sh/nubit-bin/nubit-node-linux-amd64.tar.gz | tar -xzf - --strip-components=1

# منح صلاحيات التنفيذ
RUN chmod +x nubit

# إعداد المتغيرات البيئية (Critical for Success)
ENV NUBIT_NETWORK=nubit-alphatestnet-1
ENV P2P_NETWORK=nubit-alphatestnet-1

# تشغيل النود مع تفعيل وضع الـ Light
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
