const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

/**
 * Calculates the weighted moving average
 *  of the given data array using the provided weights.
 *
 * @param {Array} data - The data array.
 * @param {Array} weights - The weights array.
 * @return {number} - The weighted moving average.
 */
function calculateWeightedMovingAverage(data, weights) {
    let weightedSum = 0;
    let weightSum = 0;

    for (let i = 0; i < data.length; i++) {
        /**
         * Calculates the weighted moving average
         * of the given data array using the provided weights.
         *
         * @param {Array} data
         * @param {Array} weights
         * @return {number}
         */
        weightedSum += data[i] * weights[i];
        weightSum += weights[i];
    }

    return weightedSum / weightSum;
}

/**
 * Calculates the moving average of an array of data.
 *
 * @param {Array} data
 * @param {number} windowSize
 * @return {number}
 */
function calculateMovingAverage(data, windowSize) {
    let sum = 0;

    for (let i = 0; i < windowSize; i++) {
        sum += data[i];
    }

    return sum / windowSize;
}

exports.scheduleTemperatureForecast = functions
    .pubsub.schedule("00 09 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        const fieldsSnapshot = await firestore.collection("fields").get();

        fieldsSnapshot.forEach(async (fieldDoc) => {
            const fieldId = fieldDoc.id;

            const forecastWindowSize = 7;

            const temperatureDataSnapshot = await firestore
                .collection("fields")
                .doc(fieldId)
                .collection("temperatures")
                .orderBy("date", "desc")
                .limit(forecastWindowSize)
                .get();

            const minTemps = [];
            const maxTemps = [];

            temperatureDataSnapshot.forEach((doc) => {
                const data = doc.data();
                minTemps.push(data.minTemp);
                maxTemps.push(data.maxTemp);
            });

            const linearWeights = [1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4];

            const minTempForecastWMA =
                calculateWeightedMovingAverage(minTemps, linearWeights);
            const maxTempForecastWMA =
                calculateWeightedMovingAverage(maxTemps, linearWeights);

            const minTempForecastMA =
                calculateMovingAverage(minTemps, forecastWindowSize);
            const maxTempForecastMA =
                calculateMovingAverage(maxTemps, forecastWindowSize);

            await firestore.collection("fields")
                .doc(fieldId)
                .collection("forecast_7day")
                .add({
                    date: admin.firestore.FieldValue.serverTimestamp(),
                    minTempForecastWMA,
                    maxTempForecastWMA,
                    minTempForecastMA,
                    maxTempForecastMA,
                });
        });

        return null;
    });

