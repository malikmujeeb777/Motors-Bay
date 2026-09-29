const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// Helper function to get sender's profile photo
async function getSenderPhotoUrl(senderId) {
  try {
    const db = getFirestore();
    const senderDoc = await db.collection("users").doc(senderId).get();
    if (senderDoc.exists) {
      const senderData = senderDoc.data();
      return senderData.photoUrl || "";
    }
    return "";
  } catch (error) {
    console.log("Error getting sender photo:", error);
    return "";
  }
}

exports.sendMessageNotification = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
  const message = event.data.data(); // New message data
  const chatId = event.params.chatId;
  const messageId = event.params.messageId;

  const db = getFirestore();

  const chatDoc = await db.collection("chats").doc(chatId).get();
  const chatData = chatDoc.data();

  if (!chatData || !chatData.participants) {
    console.log("Chat participants not found.");
    return;
  }

  const senderId = message.senderId;
  const recipientId = chatData.participants.find(id => id !== senderId);

  // Verify both sender and recipient are valid participants
  if (!chatData.participants.includes(senderId)) {
    console.log("Message sender is not a chat participant. Possible security issue.");
    return;
  }

  // ✅ Don't send notification to sender
  if (!recipientId || recipientId === senderId) {
    console.log("Recipient is sender or not found. Skipping notification.");
    return;
  }
  
  // Update the unread count for the recipient
  try {
    const unreadCount = chatData.unreadCount || {};
    const currentCount = unreadCount[recipientId] || 0;
    
    await db.collection("chats").doc(chatId).update({
      [`unreadCount.${recipientId}`]: currentCount + 1
    });
    
    console.log(`Updated unread count for recipient ${recipientId} to ${currentCount + 1}`);
  } catch (error) {
    console.error("Error updating unread count:", error);
  }

  const userDoc = await db.collection("users").doc(recipientId).get();
  const userData = userDoc.data();

  if (!userData || !userData.deviceToken) {
    console.log("No device token for recipient.");
    return;
  }

  // Get sender's name for the notification
  let senderName = "Someone";
  try {
    const senderDoc = await db.collection("users").doc(senderId).get();
    if (senderDoc.exists) {
      const senderData = senderDoc.data();
      senderName = senderData.displayName || "Someone";
    }
  } catch (error) {
    console.log("Error getting sender details:", error);
  }

  const payload = {
    notification: {
      title: `${senderName} sent you a message`,
      body: message.text || "You have a new message",
      badge: '1',
      sound: 'default'
    },
    token: userData.deviceToken,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      senderId: senderId,
      chatId: chatId,
      messageId: messageId,
      type: "chat_message",
      currentUserId: recipientId,
      senderName: senderName,
      senderPhoto: await getSenderPhotoUrl(senderId)
    },
    android: {
      notification: {
        channel_id: "chat_messages",
        priority: "high",
        visibility: "private",
      }
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: 'default',
          category: 'chat_message'
        }
      }
    }
  };

  try {
    await getMessaging().send(payload);
    console.log("Notification sent to", recipientId);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
});
