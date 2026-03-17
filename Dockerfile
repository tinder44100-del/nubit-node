# استخدام الصورة الرسمية الموثقة من NubitLabs
FROM nubitlabs/nubit-node:latest

# المتغيرات الأساسية للشبكة
ENV NUBIT_NETWORK=nubit-alphatestnet-1
ENV P2P_NETWORK=nubit-alphatestnet-1

# تعيين مسار العمل
WORKDIR /home/nubit

# تشغيل النود مباشرة (بدون VOLUME وبدون تعقيد)
ENTRYPOINT ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1"]
