---

# Type21

## Under development

Type21 is a Flutter-based mobile android application designed for rice field management using Accumulated growing degree days (AGDD)
 to calculate state of rice and forecast harvest date after get enough data( AGDD around 80% of rice max AGDD) right now only have 
 data of Hom Mali rice 105 and Sticky rice I'll use code name as KDML105 and RD6 because is easy to read and understand for me, 
 will be update in future after get enough data about other rice's max AGDD. It integrates Google Maps and fetches real-time 
 weather data to provide users with a comprehensive view of their field.
 (Specially develop and test for Thailand other country may not work properly)

## Features

- **Real-time Weather Data**: Fetch and display up-to-date weather information.
- **Google Maps Integration**: View and interact with geographical data.
- **User Authentication**: Secure login and registration system powered by Firebase.
- **Interactive UI**: Sleek and user-friendly interface for an enhanced user experience.

## Firebase Integration in Type21

Firebase offers a suite of services that are integrated into the `Type21` application:

1. **Authentication**:
    - Manage user sign-up, login, and session using Firebase Authentication.

2. **Real-time Database & Cloud Firestore**:
    - Store and retrieve user rice fields data.

3. ### Cloud Functions

Firebase Cloud Functions facilitate backend operations for the `Type21` application. These
serverless functions handle data processing, external service interactions, and various other tasks
that enhances the app's functionality. Here's a detailed overview of each function:

#### TempData

- **Purpose**: To fetch and store daily temperature data for every field.
- **Trigger**: Scheduled to activate daily at 7:00 AM (Asia/Bangkok time zone).
- **Data Flow**:
    -   1. Initiates by fetching field information from the Firestore collection "fields".
    -   2. Acquires temperature data for each field through an open weather API.
    -   3. Processes and saves the gathered temperature data back into Firestore.

#### getTemperatureDataByMonth

- **Purpose**: Calculate and store monthly accumulated temperature data for each field.
- **Trigger**: Scheduled to activate every Monday at 7:30 AM (Asia/Bangkok time zone).
- **Data Flow**:
    -   1. Fetch field information from the Firestore collection "fields".
    -   2. For each field, acquire temperature data from its respective sub-collection.
    -   3. Calculate the monthly accumulated Growing Degree Days (GDD) for each temperature data point.
    -   4. Store the calculated monthly GDD values in the Firestore sub-collection "temperatures_monthly" for each field.

#### calculateSMA (Utility Functions)

- **Purpose**: Calculate the Simple Moving Average (SMA) for a given array of values.
- **Parameters**:
    - `data`: The array of values for which the SMA is to be calculated.
    - `days`: The number of days to consider for the SMA calculation.
- **Returns**: The calculated SMA value or null if not enough data.
- **Data Flow**:
    -   1. Checks if the array of values contains enough data points for the SMA calculation.
    -   2. Calculates the SMA using the specified number of days.
    -   3. Returns the calculated SMA value.

  #### harvestForecastDate
- **Purpose**: Predict the harvest date based on accumulated GDD and a 7-day SMA of temperature
  data.
- **Trigger**: Scheduled to activate every Monday at 9:10 AM (Asia/Bangkok time zone).
- **Data Flow**:
    -   1. Fetch all field documents from the Firestore collection "fields".
    -   2. For each field, retrieve the riceMaxGdd and accumulated GDD.
    -   3. If the accumulated GDD has reached 80% of the riceMaxGdd, the function proceeds to
           forecast the harvest date.
    -   4. Fetch and process temperature data for the field to create an array of daily GDD values.
    -   5. Calculate a 7-day SMA for the GDD data.
    -   6. Use the SMA value to forecast how many more days are required to reach the riceMaxGdd.
    -   7. Calculate the forecasted harvest date and update it in the Firestore database for the field.

4. **Analytics & Crashlytics**:
    - Understand app usage patterns and user behavior with Firebase Analytics.
    - Monitor app stability with real-time crash reports from Firebase Crashlytics.

5. **Firebase Security**:
    - Robust security features ensuring data privacy and integrity.
    - Defined security rules for databases, storage, and other services ensuring authorized access.

## Getting Started

Follow these steps to get `Type21` running on your local machine for development and testing
purposes.

### Prerequisites

- Flutter SDK (latest version recommended).
- Firebase account for backend and authentication services.
- Active internet connection for fetching data.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/lighting0217/type21.git
   ```

2. Navigate to the project directory:
   ```bash
   cd type21
   ```

3. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

4. Ensure you've set up Firebase authentication for your Flutter app. Refer to Firebase
   documentation for a step-by-step guide.

### Running the App

Once you've set up the environment and installed all dependencies, run the following command:

```bash
flutter run
```

## Built With

- **Flutter**
- **Firebase**
- **Google Maps Flutter Plugin**
- **Open Weather API**

## Contributing

Contributions are what make the open-source community such an inspiring place to learn, inspire, and
create. Any contributions you make to `Type21` are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---
