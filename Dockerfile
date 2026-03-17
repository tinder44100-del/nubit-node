# استخدام الصورة الرسمية التي تحتوي على كل الملفات مسبقاً
FROM nubitlabs/nubit-node:latest

# ضبط المتغيرات لضمان التعرف على الشبكة فوراً
ENV NUBIT_NETWORK=nubit-alphatestnet-1
ENV P2P_NETWORK=nubit-alphatestnet-1

# المجلد الافتراضي للبيانات (لضمان حفظ النقاط)
VOLUME /root/.nubit

# أمر التشغيل الاحترافي الذي يتجاوز أخطاء البداية
ENTRYPOINT ["/bin/sh", "-c", "./nubit light start --p2p.network $NUBIT_NETWORK"]
