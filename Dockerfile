# =========================================
# Mina Protocol Node + Snarker Node
# High Efficiency - Single Dockerfile
# =========================================

FROM minaprotocol/mina-daemon:latest

# ------------------------------
# إعداد مجلد البيانات
# ------------------------------
ENV MINA_DATA_DIR=/root/.mina
ENV SNARKER_DATA_DIR=/root/.mina/snarker
VOLUME ["/root/.mina"]

WORKDIR /root

# ------------------------------
# تثبيت أدوات مساعدة
# ------------------------------
RUN apt update && apt install -y wget tmux htop supervisor && apt clean

# ------------------------------
# تنزيل snapshot لتسريع التشغيل
# ------------------------------
RUN echo "📥 Downloading latest snapshot..." && \
    mkdir -p $MINA_DATA_DIR && \
    wget -O /tmp/snapshot.tar.gz https://storage.googleapis.com/mina-network-binaries/mainnet_snapshot.tar.gz && \
    tar -xzf /tmp/snapshot.tar.gz -C $MINA_DATA_DIR && \
    rm /tmp/snapshot.tar.gz

# ------------------------------
# إعداد Supervisor لتشغيل Node + Snarker تلقائيًا
# ------------------------------
RUN echo "[supervisord]" > /etc/supervisor/conf.d/mina.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/mina.conf && \
    echo "[program:mina-node]" >> /etc/supervisor/conf.d/mina.conf && \
    echo "command=mina daemon -peer-list-url https://storage.googleapis.com/mina-network-binaries/mainnet_peers.txt" >> /etc/supervisor/conf.d/mina.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/mina.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/mina.conf && \
    echo "[program:snarker-node]" >> /etc/supervisor/conf.d/mina.conf && \
    echo "command=mina daemon -run-snark-worker <YOUR_PUBLIC_KEY>" >> /etc/supervisor/conf.d/mina.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/mina.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/mina.conf

# ------------------------------
# نقطة الدخول
# ------------------------------
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/mina.conf"]
