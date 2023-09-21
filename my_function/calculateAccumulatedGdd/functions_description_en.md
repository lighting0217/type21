# Function to Calculate Accumulated GDD for Each Field

This function calculates and stores the accumulated Growing Degree Days (GDD) for each field. It runs every Monday at 8:30 AM (Asia/Bangkok time). The function retrieves data for all fields from Firestore and calculates the accumulated GDD by summing up the monthly GDD values for each field. The function then saves the accumulated GDD in Firestore for each field.

## Function Configuration

* Region: asia-southeast1
* Memory: 1GB
* Scheduled Invocation Time: Every Monday at 8:30 AM (Asia/Bangkok time)
* Timezone: Asia/Bangkok
* Functionality: Calculate and store accumulated GDD for each field

## Operation

1. Retrieve data for all fields from Firestore.
2. For each field:
   * Retrieve all monthly temperature data for the field from Firestore.
   * Calculate the accumulated GDD by summing up the monthly GDD values.
   * Calculate the difference between the accumulated GDD and the field's maximum GDD.
   * Save the accumulated GDD, maximum GDD, and the difference in Firestore for that field.

## Code

```javascript
// This function calculates and stores the accumulated GDD for each field
exports.calculateAccumulatedGdd = functions
  .region("asia-southeast1")
  .runWith({ memory: "1GB" })
  .pubsub.schedule("30 08 * * 1")
  .timeZone("Asia/Bangkok")
  .onRun(async () => {
    // Start by retrieving data for all fields from Firestore
    const fieldsSnapshot = await admin
      .firestore()
      .collection("fields")
      .get();
    console.log(`Fetched ${fieldsSnapshot.size} field documents.`);

    // For each field
    for (const fieldDoc of fieldsSnapshot.docs) {
      // Retrieve the field document ID
      const fieldId = fieldDoc.id;
      // Retrieve the field document data
      const fieldData = fieldDoc.data();
      // Retrieve the maximum GDD for the field
      const maxGdd = fieldData.riceMaxGdd || 0;
      console.log(`Processing field: ${fieldId}, Max GDD: ${maxGdd}`);

      // Retrieve all monthly temperature data for the field from Firestore
      const monthlyTemperaturesSnapshot =
        await fieldDoc
          .ref
          .collection("temperatures_monthly")
          .get();

      // Start with accumulated GDD as 0
      let accumulatedGdd = 0;

      // Iterate through all monthly temperature documents
      for (const monthlyDoc of monthlyTemperaturesSnapshot.docs) {
        // Retrieve the data from the monthly temperature document
        const monthlyData = monthlyDoc.data();
        // Add the monthly GDD sum to the accumulated GDD
        accumulatedGdd += monthlyData.gddSum || 0;
      }

      // Calculate the difference between the accumulated GDD and the maximum GDD for the field
      const difference = Math.max(0, maxGdd - accumulatedGdd);

      // Save the accumulated GDD, maximum GDD, and difference in Firestore for the field
      await fieldDoc
        .ref
        .collection("accumulated_gdd")
        .doc("Accumulated GDD")
        .set({
          documentID: fieldId,
          date: admin.firestore.FieldValue.serverTimestamp(),
          accumulatedGdd,
          maxGdd,
          difference,
        });

      // Print various data to the console
      console.log(
        `Accumulated GDD for field ${fieldId}:
          ${accumulatedGdd}. Difference to maxGDD: ${difference}`);
    }

    // Display a message indicating that the accumulated GDD calculation is complete
    console.log("Accumulated GDD calculation completed.");
  });
```
