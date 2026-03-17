# استخدام نسخة لينكس خام ومستقرة جداً
FROM debian:bullseye-slim

# تثبيت الأدوات الأساسية والشهادات لفك أي حظر
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    ca-certificates \
    && apt-get clean

WORKDIR /app

# استخدام رابط التحميل المباشر مع تجاوز فحص الشهادات إذا لزم الأمر
RUN curl -k -L https://nubit.sh/nubit-bin/nubit-node-linux-amd64.tar.gz | tar -xzf - --strip-components=1

# إعداد المتغيرات البيئية لضمان عمل المزامنة
ENV NUBIT_NETWORK=nubit-alphatestnet-1
ENV P2P_NETWORK=nubit-alphatestnet-1

# منح صلاحيات كاملة للملفات التنفيذية
RUN chmod +x nubit nkey

# تشغيل النود بأمر مباشر يضمن عدم التوقف
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
