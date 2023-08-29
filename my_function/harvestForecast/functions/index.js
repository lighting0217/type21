const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.harvestForecast = functions
    .pubsub
    .schedule("10 09 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        const fieldsSnapshot = await admin
            .firestore()
            .collection("fields").get();
        console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

        fieldsSnapshot.forEach(async (doc) => {
            const fieldData = doc.data();
            const fieldId = doc.id;

            const selectedDate = fieldData.selectedDate.toDate();
            const riceMaxGdd = fieldData.riceMaxGdd;

            console.log(
                `Processing field: ${fieldId}.
         Selected date: ${selectedDate}. 
         Max GDD: ${riceMaxGdd}`);

            const agddDoc = await admin.firestore()
                .collection("fields")
                .doc(fieldId)
                .collection("accumulated_gdd")
                .doc("Accumulated GDD")
                .get();
            const accumulatedGdd =
                agddDoc.data().accumulatedGdd;

            console.log(`For field: ${fieldId},
     Accumulated GDD: ${accumulatedGdd}`);

            const thresholdGdd = riceMaxGdd * 0.8;
            const currentDate = new Date();
            const forecastedDays = 20;
            if (selectedDate <= currentDate &&
                accumulatedGdd >= thresholdGdd) {
                console
                    .log(`Forecasting harvest date for field: ${fieldId}`);

                const forecastedHarvestDate = new Date(selectedDate);
                forecastedHarvestDate
                    .setDate(forecastedHarvestDate
                        .getDate() + forecastedDays);

                await admin
                    .firestore()
                    .collection("fields")
                    .doc(fieldId).update({
                        forecastedHarvestDate:
                        forecastedHarvestDate,
                    });

                console.log(`Updated field: ${fieldId}
       with forecasted harvest date: ${forecastedHarvestDate}`);
            } else {
                console.log(`Skipping field:
       ${fieldId} as conditions are not met.`);
            }
        });

        console.log("Finished processing all fields.");
        return null;
    });
