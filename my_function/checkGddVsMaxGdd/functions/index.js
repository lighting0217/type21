/**
 * Cloud Function that checks if the accumulated Growing Degree Days (GDD) for each field exceeds the maximum GDD for rice growth.
 * Runs every Monday at 8:00 AM Bangkok time.
 * @function
 * @name checkGddVsMaxGdd
 * @type {functions.CloudFunction}
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.checkGddVsMaxGdd = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("0 8 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        try {
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();

            for (const fieldDoc of fieldsSnapshot.docs) {
                const fieldData = fieldDoc.data();
                const riceMaxGdd = fieldData.riceMaxGdd;
                const fieldId = fieldDoc.id;

                const monthlyTemperaturesSnapshot = await fieldDoc
                    .ref
                    .collection("temperatures_monthly")
                    .get();

                for (const monthlyTemperatureDoc
                    of
                    monthlyTemperaturesSnapshot
                        .docs) {
                    const monthlyTemperatureData =
                        monthlyTemperatureDoc
                            .data();
                    const monthYear =
                        monthlyTemperatureData
                            .documentID;
                    const gddSum =
                        monthlyTemperatureData
                            .gddSum;

                    if (gddSum >= riceMaxGdd) {
                        console
                            .log(
                                `Field ${fieldId},
                             Month ${monthYear}: GDD exceeded riceMaxGdd`);
                    } else {
                        console
                            .log(
                                `Field ${fieldId},
                             Month ${monthYear}: GDD is within range`);
                    }
                }
            }

            console
                .log(
                    "GDD vs Max GDD check completed");
            return null;
        } catch (error) {
            console
                .error(
                    "Error checking GDD vs Max GDD:", error);
            return null;
        }
    });
