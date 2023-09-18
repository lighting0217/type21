---

# Type21

## Under development

Type21 is a Flutter-based mobile android application designed for rice field management using AGDD
to calculate state of rice and forecast harvest date after get enough data(AGDD around 80% of rice
max AGDD) right now only have data of Hom mali rice 105 and Sticky rice rd6 (i'll use code name as
KDML105 and RD6 because is easy to read and under stand for me)will be update in future after get
enough data about other rice max AGDD. It integrates Google Maps and fetches real-time weather data
to provide users with a comprehensive view of their field.
(spicily develop and test in Thailand other country may not work properly)

## Features

- **Real-time Weather Data**: Fetch and display up-to-date weather information.
- **Google Maps Integration**: View and interact with geographical data.
- **User Authentication**: Secure login and registration system powered by Firebase.
- **Interactive UI**: Sleek and user-friendly interface for an enhanced user experience.

## Firebase Integration in Type21

Firebase offers a suite of services that are integrated into the `Type21` application:

1. **Authentication**:
    - Manage user sign-up, login, and session using Firebase Authentication.
    - Supports multiple authentication methods including email/password and Google sign-in.

2. **Real-time Database & Cloud Firestore**:
    - Store and retrieve user preferences, history, and other specific data.
    - Provides real-time sync across devices and offline support.

3. ### Cloud Functions

Firebase Cloud Functions facilitate backend operations for the `Type21` application. These
serverless functions handle data processing, external service interactions, and various other tasks
that enhance the app's functionality. Here's a detailed overview of each function:

#### TempData

- **Purpose**: To fetch and store daily temperature data for every field.
- **Trigger**: Scheduled to activate daily at 7:00 AM (Asia/Bangkok timezone).
- **Data Flow**:
  -
        1. Initiates by fetching field information from the Firestore collection "fields".
    -
        2. Acquires temperature data for each field through an external weather API.
    -
        3. Processes and saves the gathered temperature data back into Firestore.

#### CheckWeather

- **Purpose**: Regularly checks weather conditions and updates the Firestore database accordingly.
- **Trigger**: Scheduled execution (specific intervals can be specified based on requirements).
- **Data Flow**:
  -
        1. Retrieves a list of specified regions or locations from Firestore.
    -
        2. For each location, it contacts an external weather service to get current weather
           conditions.
    -
        3. Updates Firestore with the latest weather data for each location.

#### UpdateUserData

- **Purpose**: Updates user-specific data in the Firestore database.
- **Trigger**: Activates upon specific user actions or changes in user-related data.
- **Data Flow**:
  -
        1. Detects changes or actions related to user data (e.g., profile update, preferences
           change).
    -
        2. Processes and validates the new data provided.
    -
        3. Updates the Firestore database with the new user data.

#### CalculateAGDD

- **Purpose**: Computes the Accumulated Growing Degree Days (AGDD) for specific crops.
- **Trigger**: Scheduled to run at specific intervals or upon request.
- **Data Flow**:
  -
        1. Gathers temperature and crop data from Firestore.
    -
        2. Computes AGDD using crop-specific base temperatures and daily temperature data.
    -
        3. Stores the calculated AGDD values back into Firestore.

#### NotifyUsers

- **Purpose**: Sends notifications to users based on specific conditions or triggers.
- **Trigger**: Based on specified conditions like weather changes, AGDD thresholds, etc.
- **Data Flow**:
  -
        1. Monitors Firestore for changes or conditions that should trigger notifications.
    -
        2. Processes the data to determine which users should receive notifications.
    -
        3. Uses Firebase Cloud Messaging to dispatch notifications to the relevant users.

#### getTemperatureDataByMonth

- **Purpose**: Calculate and store monthly accumulated temperature data for each field.
- **Trigger**: Scheduled to activate every Monday at 7:30 AM (Asia/Bangkok timezone).
- **Data Flow**:
  -
        1. Fetch field information from the Firestore collection "fields".
    -
        2. For each field, acquire temperature data from its respective sub-collection.
    -
        3. Calculate the monthly accumulated Growing Degree Days (GDD) for each temperature data
           point.
    -
        4. Store the calculated monthly GDD values in the Firestore sub-collection "
           temperatures_monthly" for each field.

#### calculateSMA (Utility Functions)

- **Purpose**: Calculate the Simple Moving Average (SMA) for a given array of values.
- **Parameters**:
    - `data`: The array of values for which the SMA is to be calculated.
    - `days`: The number of days to consider for the SMA calculation.
- **Returns**: The calculated SMA value or null if not enough data.
- **Data Flow**:
  -
        1. Checks if the array of values contains enough data points for the SMA calculation.
    -
        2. Calculates the SMA using the specified number of days.
    -
        3. Returns the calculated SMA value.

  #### harvestForecastDate
- **Purpose**: Predict the harvest date based on accumulated GDD and a 7-day SMA of temperature
  data.
- **Trigger**: Scheduled to activate every Monday at 9:10 AM (Asia/Bangkok timezone).
- **Data Flow**:
  -
        1. Fetch all field documents from the Firestore collection "fields".
    -
        2. For each field, retrieve the riceMaxGdd and accumulated GDD.
    -
        3. If the accumulated GDD has reached 80% of the riceMaxGdd, the function proceeds to
           forecast the harvest date.
    -
        4. Fetch and process temperature data for the field to create an array of daily GDD values.
    -
        5. Calculate a 7-day SMA for the GDD data.
    -
        6. Use the SMA value to forecast how many more days are required to reach the riceMaxGdd.
    -
        7. Calculate the forecasted harvest date and update it in the Firestore database for the
           field.

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
