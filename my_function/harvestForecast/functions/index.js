const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.harvestForecastDate = functions
    .pubsub
    .schedule("10 09 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        const fieldsSnapshot = await admin
            .firestore()
            .collection("fields")
            .get();
        console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

        fieldsSnapshot.forEach(async (doc) => {
            const fieldData = doc.data();
            const fieldId = doc.id;
            const riceMaxGdd = fieldData.riceMaxGdd;

            const agddDoc = await admin.firestore()
                .collection("fields")
                .doc(fieldId)
                .collection("accumulated_gdd")
                .doc("Accumulated GDD")
                .get();

            const accumulatedGdd = agddDoc.data().accumulatedGdd;
            const accumulatedGddDate = agddDoc.data().date.toDate();

            const temperatureSnapshot = await admin.firestore()
                .collection("fields")
                .doc(fieldId)
                .collection("temperatures")
                .orderBy("date")
                .get();

            let forecastedDate = null;
            let currentGdd = 0;

            temperatureSnapshot.forEach((tempDoc) => {
                const tempData = tempDoc.data();
                const tempGdd = tempData.gdd;
                const tempDate = tempData.date.toDate();

                if (tempDate > accumulatedGddDate) {
                    const gddSinceLastUpdate = tempGdd - currentGdd;
                    currentGdd = tempGdd;

                    if (accumulatedGdd + gddSinceLastUpdate >= riceMaxGdd) {
                        const daysSinceLastUpdate = Math
                            .ceil((riceMaxGdd - accumulatedGdd) / gddSinceLastUpdate);
                        forecastedDate = new Date(tempDate);
                        forecastedDate
                            .setDate(forecastedDate
                                .getDate() + daysSinceLastUpdate);
                        return false; // Stop iterating
                    }
                }
            });

            if (forecastedDate) {
                await admin
                    .firestore()
                    .collection("fields")
                    .doc(fieldId)
                    .update({
                        forecastedHarvestDate: forecastedDate,
                    });

                console
                    .log(`Forecasted harvest date for field ${fieldId}:
           ${forecastedDate}`);
            } else {
                console.log(`Skipping field ${fieldId} as conditions are not met.`);
            }
        });

        console.log("Finished processing all fields.");
        return null;
    });
