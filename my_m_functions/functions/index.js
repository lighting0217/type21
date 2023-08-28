/* eslint-disable linebreak-style */
// eslint-disable-next-line linebreak-style
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment-timezone");
admin.initializeApp();
exports.getTemperatureDataByMonth = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("30 07 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        try {
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();

            for (const fieldDoc of fieldsSnapshot.docs) {
                const temperatureSnapshot = await fieldDoc
                    .ref
                    .collection("temperatures")
                    .get();

                const monthlyGdd = {};

                for (const temperatureDoc of temperatureSnapshot.docs) {
                    const temperatureData = temperatureDoc.data();
                    const date = temperatureData.date.toDate();
                    const monthYear = moment(date).format("MMMM YYYY");
                    const gdd = temperatureData.gdd || 0;

                    if (!monthlyGdd[monthYear]) {
                        monthlyGdd[monthYear] = {
                            date: admin.firestore.FieldValue.serverTimestamp(),
                            documentID: temperatureData.documentID,
                            gddSum: 0,
                        };
                    }
                    monthlyGdd[monthYear].gddSum += gdd;
                }

                for (const [monthYear, data] of Object.entries(monthlyGdd)) {
                    const monthDocRef = fieldDoc.ref
                        .collection("temperatures_monthly")
                        .doc(monthYear);

                    await monthDocRef.set(data);

            console
                .log(`Field ${fieldDoc.id}:
             Month ${monthYear} GDD Sum = ${data.gddSum}`);
                }
            }

            console.log("Temperature data by month added/updated successfully");
            return null;
        } catch (error) {
            console
                .error("Error adding/updating temperature data by month:",
                    error);
            return null;
        }
    });
