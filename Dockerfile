# =====================================
# NodeOps Node Dockerfile - 2026
# Node واحد عالي الأداء
# =====================================

# Base image
FROM ubuntu:22.04

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV NODEOPS_DATA=/app/data

# 1. تحديث النظام وتثبيت الأدوات المطلوبة
RUN apt update && apt upgrade -y && \
    apt install -y git curl build-essential docker.io tmux screen wget unzip sudo && \
    apt clean && rm -rf /var/lib/apt/lists/*

# 2. إنشاء مجلد بيانات Node
RUN mkdir -p $NODEOPS_DATA
WORKDIR /app

# 3. تنزيل NodeOps Node image الرسمية
# استخدم نسخة ثابتة إذا وجدت
RUN git clone https://github.com/nodeops/node.git nodeops-node

WORKDIR /app/nodeops-node

# 4. بناء Node (إذا مطلوب)
# يمكنك التعليق إذا تم استخدام Docker image رسمي
RUN ./build.sh

# 5. إنشاء ملف تشغيل Node
RUN echo '#!/bin/bash\n\
echo "🚀 Starting NodeOps Node..."\n\
./nodeops-node --data-dir $NODEOPS_DATA\n\
' > start-node.sh && chmod +x start-node.sh

# 6. تعيين نقطة الدخول لتشغيل Node تلقائيًا
ENTRYPOINT ["./start-node.sh"]
