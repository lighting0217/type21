const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
/**
 * Calculate and store the accumulated GDD for each field.
 * @returns {Promise<null>}
 */
exports.calculateAccumulatedGdd = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("30 08 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async () => {
        console.log("Starting to calculate accumulated GDD...");

        try {
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();
            console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

            for (const fieldDoc of fieldsSnapshot.docs) {
                const fieldId = fieldDoc.id;
                const fieldData = fieldDoc.data();
                const maxGdd = fieldData.riceMaxGdd || 0;
                console.log(`Processing field: ${fieldId}, Max GDD: ${maxGdd}`);

                const monthlyTemperaturesSnapshot =
                    await fieldDoc
                        .ref
                        .collection("temperatures_monthly")
                        .get();
                let accumulatedGdd = 0;

                for (const monthlyDoc of monthlyTemperaturesSnapshot.docs) {
                    const monthlyData = monthlyDoc.data();
                    accumulatedGdd += (monthlyData.gddSum || 0);
                }

                const difference = Math.max(0, maxGdd - accumulatedGdd);

                await fieldDoc
                    .ref
                    .collection("accumulated_gdd")
                    .doc("Accumulated GDD")
                    .set({
                        documentID: fieldId,
                        date: admin.firestore.FieldValue.serverTimestamp(),
                        accumulatedGdd,
                        maxGdd,
                        difference,
                    });

                console.log(
                    `Accumulated GDD for field ${fieldId}:
             ${accumulatedGdd}. Difference to maxGDD: ${difference}`);
            }

            console.log("Accumulated GDD calculation completed.");
        } catch (error) {
            console.error("Error calculating accumulated GDD:", error);
        }

        return null;
    });
