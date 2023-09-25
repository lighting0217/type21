const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Calculates the Simple Moving Average (SMA) of an array of data for a given number of days.
 * @param {number[]} data - The array of data to calculate the SMA for.
 * @param {number} days - The number of days to calculate the SMA for.
 * @returns {number|null} - The calculated SMA, or null if there is not enough data.
 */
function calculateSMA(data, days) {
    if (data.length < days) {
        console.warn("Not enough data for SMA calculation.");
        return null;
    }

    let sum = 0;
    for (let i = 0; i < days; i++) {
        sum += data[data.length - i - 1];
    }

    return sum / days;
}


exports.harvestForecastDate = functions
    .region("asia-southeast1")
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

            if (!agddDoc.exists) {
                console.warn(
                    `No accumulated GDD found for field ${fieldId}. Skipping.`);
                return;
            }

            const accumulatedGdd = agddDoc.data().accumulatedGdd;
            const eightyPercentMaxGdd = 0.8 * riceMaxGdd;

            if (accumulatedGdd < eightyPercentMaxGdd) {
                console.info(
                    `Field ${fieldId} has not reached 80% of Max GDD. Skipping.`);
                return;
            }

            console.log(`Field ID: ${fieldId}`);
            console.log(`Rice Max GDD: ${riceMaxGdd}`);
            console.log(`Accumulated GDD: ${accumulatedGdd}`);
            console.log(`80% of Max GDD: ${eightyPercentMaxGdd}`);

            const temperatureSnapshot = await admin.firestore()
                .collection("fields")
                .doc(fieldId)
                .collection("temperatures")
                .orderBy("date")
                .get();

            if (temperatureSnapshot.empty) {
                console.warn(
                    `No temperature data found for field ${fieldId}. Skipping.`);
                return;
            }

            const gddData = [];
            temperatureSnapshot.forEach((tempDoc) => {
                gddData.push(tempDoc.data().gdd);
            });

            const sma = calculateSMA(gddData, 7); // Calculate 7-day SMA

            if (!sma) {
                console.warn(
                    `Unable to calculate SMA for field ${fieldId}. Skipping.`);
                return;
            }

            let daysRequired = 0;
            let forecastedAgdd = accumulatedGdd;

            while (forecastedAgdd < riceMaxGdd) {
                forecastedAgdd += sma;
                daysRequired++;
            }

            daysRequired = Math.ceil(daysRequired);
            const forecastedDate = new Date();
            forecastedDate.setDate(forecastedDate.getDate() + daysRequired);

            await admin
                .firestore()
                .collection("fields")
                .doc(fieldId)
                .update({
                    forecastedHarvestDate: forecastedDate,
                });

            console.log(
                `Forecasted harvest date for field ${fieldId}: ${forecastedDate}`);
        });

        console.log("Finished processing all fields.");
        return null;
    });
