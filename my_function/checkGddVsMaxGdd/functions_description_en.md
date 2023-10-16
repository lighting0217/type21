# Function to Check GDD Against Max GDD

This function checks the Growing Degree Days (GDD) for each field against the specified Max GDD. It
runs every Monday at 8:00 AM (Asia/Bangkok time). The function retrieves data for all fields and
monthly temperature data from Firestore and calculates the GDD for each field. If the GDD for a
field exceeds the Max GDD, the function prints a notification message to the console.

## Function Configuration

* Region: asia-southeast1
* Memory: 1GB
* Scheduled Invocation Time: Every Monday at 8:00 AM (Asia/Bangkok time)
* Timezone: Asia/Bangkok
* Functionality: Check GDD for each field against Max GDD

## Operation

1. Retrieve data for all fields and monthly temperature data from Firestore.
2. For each field:
    * Calculate the GDD for that field.
    * If the GDD for the field exceeds the Max GDD:
        * Print a notification message to the console.

## Benefits

This function is useful for farmers to monitor the GDD for each field and receive notifications if
the GDD for any field exceeds the specified Max GDD. This helps farmers make appropriate decisions
regarding field management.

## Limitations

This function has some limitations, including:

* The function calculates GDD using base temperatures for rice growth, which may vary depending on
  rice varieties.
* The function calculates GDD using monthly average temperatures, which may not be as accurate as
  daily temperature measurements.

## Code

```javascript
// Function to check GDD against Max GDD
exports.checkGddVsMaxGdd = functions
    .region("asia-southeast1")
    .runWith({ memory: "1GB" })
    .pubsub.schedule("0 8 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        try {
            // 1. Retrieve data for all fields and monthly temperature data from Firestore
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();

            // 2. For each field
            for (const fieldDoc of fieldsSnapshot.docs) {
                // Retrieve the field document ID
                const fieldId = fieldDoc.id;
                // Retrieve the field document data
                const fieldData = fieldDoc.data();
                // Retrieve the Max GDD for the field
                const riceMaxGdd = fieldData.riceMaxGdd;

                // 3. Calculate the GDD for that field
                const monthlyTemperaturesSnapshot = await fieldDoc
                    .ref
                    .collection("temperatures_monthly")
                    .get();

                let accumulatedGdd = 0;
                for (const monthlyTemperatureDoc of monthlyTemperaturesSnapshot.docs) {
                    const monthlyTemperatureData = monthlyTemperatureDoc.data();
                    const monthlyGddSum = monthlyTemperatureData.gddSum;
                    accumulatedGdd += monthlyGddSum;
                }

                // 4. If the GDD for the field exceeds the Max GDD
                if (accumulatedGdd >= riceMaxGdd) {
                    // Print a notification message to the console
                    console.log(
                        `Field ${fieldId},
                        Month ${monthlyTemperatureData.documentID}: GDD exceeded riceMaxGdd`);
                }
            }

            // 5. Print a message indicating that the GDD vs Max GDD check is completed
            console.log("GDD vs Max GDD check completed");
            return null;
        } catch (error) {
            // Print an error message to the console
            console.log("Error checking GDD vs Max GDD:", error);
            return null;
        }
    });
```
