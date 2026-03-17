# السحب من المستودع الرسمي المباشر
FROM nubitlabs/nubit-node:latest

# إعداد المتغيرات البيئية الضرورية للشبكة
ENV NUBIT_NETWORK=nubit-alphatestnet-1
ENV P2P_NETWORK=nubit-alphatestnet-1

# تعيين مسار العمل الافتراضي
WORKDIR /home/nubit

# أمر التشغيل المباشر والبسيط
# أضفنا --non-interactive لتجنب التوقف عند طلب مدخلات
CMD ["./nubit", "light", "start", "--p2p.network", "nubit-alphatestnet-1", "--non-interactive"]
