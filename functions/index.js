const admin = require("firebase-admin");

admin.initializeApp();
const firestore = admin.firestore();
const {onValueCreated} = require("firebase-functions/v2/database");

exports.sendNewMessageNotification = onValueCreated(
    "/messages/{recipientId}/{messageId}",
    async (event) => {
      const messageData = event.data.val();
      const recipientId = event.params.recipientId;
      const senderId = messageData.senderID;

      const [senderSnapshot, recipientSnapshot] = await Promise.all([
        firestore.collection("users").doc(senderId).get(),
        firestore.collection("users").doc(recipientId).get(),
      ]);

      const senderName = senderSnapshot.exists ?
        senderSnapshot.data().username : "Неизвестный пользователь";
      const recipientToken = recipientSnapshot.exists ?
        recipientSnapshot.data().fcmToken : null;

      if (!recipientToken) {
        console.log(`❌ Нет FCM-токена для получателя: ${recipientId}`);
        return null;
      }

      let notificationBody = "[Новое сообщение]";
      if (messageData.text) {
        notificationBody = "Новое сообщение";
      } else if (messageData.imageUrl) {
        notificationBody = "Изображение";
      }

      const message = {
        token: recipientToken,
        notification: {
          title: senderName,
          body: notificationBody,
        },
        data: {
          senderId: senderId,
          recipientId: recipientId,
          messageId: event.params.messageId,
        },
        android: {
          notification: {
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      };

      try {
        const response = await admin.messaging().send(message);
        console.log(`✅ Уведомление отправлено ${recipientId}`, response);
      } catch (error) {
        console.error("❌ Ошибка отправки уведомления:", error);
      }
    });
