/* eslint-disable linebreak-style */
const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");
const moment = require("moment-timezone");
admin.initializeApp();
const apiKey = "a7296ca666d968ee7312a3565a3a28fa";

/**
 * Fetch and store daily temperature data for each field.
 * @returns {Promise<null>}
 */
exports.TempData = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("0 7 * * *")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        console.log("Starting to fetch daily temperature data...");

        try {
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();
            console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

            for (const fieldDoc of fieldsSnapshot.docs) {
                const fieldData = fieldDoc.data();
                const {latitude, longitude} = fieldData.polygons[0];
                const apiUrl = `https://api.openweathermap.org/data/2.5/onecall?lat=${latitude}&lon=${longitude}&exclude=minutely,hourly&appid=${apiKey}&units=metric`;
                const response = await axios.get(apiUrl);
                const dailyData = response.data.daily;

                for (const dailyDatum of dailyData) {
                    const dateThai = moment
                        .unix(dailyDatum.dt)
                        .utcOffset(7).format("MMMM D, YYYY");
                    const documentID = fieldDoc.id;
                    const minTemp = dailyDatum.temp.min;
                    const maxTemp = dailyDatum.temp.max;
                    const gdd = (minTemp + maxTemp) / 2 - 9;

                    const temperatureDocRef = fieldDoc
                        .ref
                        .collection("temperatures")
                        .doc(dateThai);

                    if (await temperatureDocRef.get().exists) {
                        await temperatureDocRef
                            .update({
                                documentID,
                                minTemp,
                                maxTemp,
                                date: admin
                                    .firestore
                                    .FieldValue
                                    .serverTimestamp(),
                                gdd
                            });
                    } else {
                        await temperatureDocRef
                            .set({
                                documentID,
                                minTemp,
                                maxTemp,
                                date: admin
                                    .firestore
                                    .FieldValue
                                    .serverTimestamp(),
                                gdd,
                            });
                    }
                }
            }

            console.log("Temperature data fetched and saved successfully.");
        } catch (error) {
            console.error("Error fetching temperature data:", error);
        }

        return null;
    });
