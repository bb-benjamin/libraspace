const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// FUNCTION 1: notifyWhenFull
// Fires when a library JUST became full
exports.notifyWhenFull = functions.firestore
  .document("libraries/{libraryId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const libraryId = context.params.libraryId;
    const libraryName = after.title || "A library";

    const wasFull = before.occupiedSeats >= before.totalSeats;
    const isNowFull = after.occupiedSeats >= after.totalSeats;

    if (wasFull || !isNowFull) {
      console.log(`${libraryName}: no full notification needed.`);
      return null;
    }

    console.log(`${libraryName} just became FULL. Sending notifications...`);

    const message = {
      notification: {
        title: "⚠️ Library Now Full",
        body: `${libraryName} is now full. Check LibraSpace for other options nearby.`,
      },
      data: { libraryId: libraryId, screen: "home" },
      topic: "all_users",
    };

    try {
      const response = await messaging.send(message);
      console.log(`Notification sent. Response: ${response}`);
      return null;
    } catch (error) {
      console.error(`Failed to send notification: ${error}`);
      return null;
    }
  });

// FUNCTION 2: notifyWhenSeatOpens
// Fires when a library that WAS full gets a free seat
exports.notifyWhenSeatOpens = functions.firestore
  .document("libraries/{libraryId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const libraryName = after.title || "A library";
    const libraryId = context.params.libraryId;

    const wasFull = before.occupiedSeats >= before.totalSeats;
    const nowHasSpace = after.occupiedSeats < after.totalSeats;

    if (!wasFull || !nowHasSpace) return null;

    console.log(`${libraryName} just got a free seat! Notifying students...`);

    const message = {
      notification: {
        title: "🟢 Seat Just Opened!",
        body: `A seat just became available at ${libraryName}. Go now before it fills up!`,
      },
      data: { libraryId: libraryId, screen: "home" },
      topic: "all_users",
    };

    try {
      await messaging.send(message);
      console.log("Seat available notification sent.");
    } catch (error) {
      console.error(`Failed to send notification: ${error}`);
    }
    return null;
  });

// FUNCTION 3: sendDailyReminder
// Runs every morning at 8am Ghana time
// NOTE: Requires Blaze billing plan to deploy
// Code is ready — deploy when billing is activated
exports.sendDailyReminder = functions.pubsub
  .schedule("every day 08:00")
  .timeZone("Africa/Accra")
  .onRun(async (context) => {
    console.log("Sending daily morning reminder...");

    const librariesSnapshot = await db.collection("libraries").get();
    let availableCount = 0;
    librariesSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.occupiedSeats < data.totalSeats) availableCount++;
    });

    const message = {
      notification: {
        title: "📚 Good Morning from LibraSpace",
        body:
          availableCount > 0
            ? `${availableCount} ${availableCount === 1 ? "library has" : "libraries have"} seats available right now.`
            : "All libraries are currently full. Check LibraSpace throughout the day.",
      },
      data: { screen: "home" },
      topic: "all_users",
    };

    try {
      await messaging.send(message);
      console.log("Daily reminder sent successfully.");
    } catch (error) {
      console.error(`Failed to send daily reminder: ${error}`);
    }
    return null;
  });
