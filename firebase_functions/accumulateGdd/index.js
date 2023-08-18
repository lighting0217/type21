const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
module.exports.accumulateGDD = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("30 09 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async () => {
        try {
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();

            for (const fieldDoc of fieldsSnapshot.docs) {
                const temperatureMonthlySnapshot = await fieldDoc
                    .ref
                    .collection("temperatures_monthly")
                    .get();

                let totalGddSum = 0;

                for (const monthlyDoc of temperatureMonthlySnapshot.docs) {
                    const monthlyData = monthlyDoc.data();
                    totalGddSum += monthlyData.gddSum;
                }

                await fieldDoc.ref
                    .collection("temperatures_monthly")
                    .doc("Accumulated Gdd")
                    .set({
                        AGDD: totalGddSum,
                        date: admin.firestore.FieldValue.serverTimestamp(),
                        documentID: fieldDoc.id,
                    });
            }

            console
                .log(
                    "Accumulated GDD for each field added");
            return null;
        } catch (error) {
            console
                .error(
                    "Error adding accumulated GDD to temperatures_monthly:"
                    , error);
            return null;
        }
    });
