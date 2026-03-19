# =========================================
# NodeOps Node Dockerfile 2026 - Optimized
# Node واحد عالي الأداء + snapshot + logs
# =========================================

# استخدام Docker image الرسمي
FROM nodeops/node:latest

# إعداد متغيرات البيئة
ENV NODEOPS_DATA=/app/data
ENV NODEOPS_SNAPSHOT_URL=https://nodeops.network/snapshots/latest-snapshot.tar.gz

# مجلد بيانات دائم
VOLUME ["/app/data"]

# تعيين مجلد العمل
WORKDIR /app

# تثبيت أدوات مساعدة
RUN apt update && apt install -y wget tar tmux htop && apt clean

# تنزيل أحدث snapshot لتسريع التشغيل
RUN echo "📥 Downloading latest NodeOps snapshot..." && \
    mkdir -p $NODEOPS_DATA && \
    wget -O /tmp/snapshot.tar.gz $NODEOPS_SNAPSHOT_URL && \
    tar -xzf /tmp/snapshot.tar.gz -C $NODEOPS_DATA && \
    rm /tmp/snapshot.tar.gz

# إنشاء سكريبت تشغيل Node
RUN echo '#!/bin/bash\n\
echo "🚀 Starting NodeOps Node with snapshot..."\n\
nodeops-node --data-dir $NODEOPS_DATA\n\
' > start-node.sh && chmod +x start-node.sh

# نقطة الدخول
ENTRYPOINT ["./start-node.sh"]
