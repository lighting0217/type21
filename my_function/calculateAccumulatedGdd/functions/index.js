const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.calculateAccumulatedGdd = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("30 08 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async () => {
        try {
            console.log("Calculating accumulated GDD...");

            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields").get();

            for (const fieldDoc of fieldsSnapshot.docs) {
                const fieldId = fieldDoc.id;
                console.log(`Processing field: ${fieldId}`);

                const monthlyTemperaturesSnapshot = await fieldDoc
                    .ref
                    .collection("temperatures_monthly")
                    .get();

                let accumulatedGdd = 0;

                for (const monthlyDoc of monthlyTemperaturesSnapshot.docs) {
                    const monthlyData = monthlyDoc.data();
                    const gddSum = monthlyData.gddSum || 0;

                    accumulatedGdd += gddSum;
                }

                const accumulatedGddDocRef = fieldDoc.ref
                    .collection("accumulated_gdd")
                    .doc("Accumulated GDD");

                await accumulatedGddDocRef.set({
                    documentID: fieldId,
                    date: admin.firestore.FieldValue.serverTimestamp(),
                    accumulatedGdd,
                });

                console.log(`Accumulated GDD for field ${fieldId}:
           ${accumulatedGdd}`);
            }

            console.log("Accumulated GDD calculation completed.");
            return null;
        } catch (error) {
            console.error("Error calculating accumulated GDD:", error);
            return null;
        }
    });
