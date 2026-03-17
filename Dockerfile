FROM ubuntu:22.04

# تثبيت المتطلبات الأساسية
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# تحميل نسخة النود الرسمية وفك ضغطها
RUN curl -sL https://nubit.sh/nubit-bin/nubit-node-linux-amd64.tar.gz | tar -xzf - --strip-components=1

# تعيين المتغيرات
ENV NUBIT_NETWORK=nubit-alphatestnet-1

# أمر التشغيل النهائي
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
