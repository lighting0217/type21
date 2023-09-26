/* eslint linebreak-style: ["error", "windows"]*/
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment-timezone");
admin.initializeApp();
/**
 * Calculate and store the monthly accumulated temperature data.
 * @returns {Promise<null>}
 */
exports.getTemperatureDataByMonth = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("30 07 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        console.log("Starting to fetch temperature data by month...");

        try {
            const fieldsSnapshot = await
                admin
                    .firestore()
                    .collection("fields")
                    .get();
            console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

            for (const fieldDoc of fieldsSnapshot.docs) {
                /**
                 * Retrieves temperature data by month from a Firestore collection.
                 * @param {Object} fieldDoc - The document containing the collection of temperature data.
                 * @returns {Promise<Object>} - A promise that resolves with the temperature data snapshot.
                 */
                const temperatureSnapshot = await
                    fieldDoc
                        .ref
                        .collection("temperatures")
                        .get();
                const monthlyGdd = {};

                for (const temperatureDoc of temperatureSnapshot.docs) {
                    const temperatureData = temperatureDoc.data();
                    const date = temperatureData.date.toDate();
                    const monthYear = moment(date).format("MMMM YYYY");
                    const gdd = temperatureData.gdd || 0;

                    monthlyGdd[monthYear] =
                        monthlyGdd[monthYear] || {
                            date: admin
                                .firestore
                                .FieldValue
                                .serverTimestamp(),
                            documentID: temperatureData.documentID,
                            gddSum: 0
                        };
                    monthlyGdd[monthYear].gddSum += gdd;
                }

                for (const [monthYear, data] of Object.entries(monthlyGdd)) {
                    await fieldDoc
                        .ref
                        .collection("temperatures_monthly")
                        .doc(monthYear)
                        .set(data);
                    console
                        .log(
                            `Field ${fieldDoc.id}:
                 Month ${monthYear}
                  GDD Sum = ${data.gddSum}`);
                }
            }

            console.log("Temperature data by month added/updated successfully.");
        } catch (error) {
            console.error(
                "Error adding/updating temperature data by month:",
                error);
        }

        return null;
    });
