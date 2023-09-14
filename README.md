
---

# Type21
## Under development
Type21 is a Flutter-based mobile android application designed for rice field management using AGDD to calculate state of rice and forecast harvest date after get enough data(AGDD around 80% of rice max AGDD) right now only have data of Hom mali rice 105 and Sticky rice rd6 (i'll use code name as KDML105 and RD6 becasue is easy to read and under stand for me)will be update in future after get enough data about other rice max AGDD. It integrates Google Maps and fetches real-time weather data to provide users with a comprehensive view of their field.
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
    - Supports multiple authentication methods including email/password and/* Google sign-in.*/

2. **Real-time Database & Cloud Firestore**:
    - Store and retrieve user preferences, history, and other specific data.
    - Provides real-time sync across devices and offline support.

3. **Cloud Functions**:
    - Serverless functions for backend operations.
    - Functions include:
        - `addAdminRole`: Assigns an 'admin' role to a specified user.
        - `getWeatherData`: Fetches weather data based on given parameters.
    - These functions streamline various backend operations and provide extensibility to the app.

4. **Analytics & Crashlytics**:
    - Understand app usage patterns and user behavior with Firebase Analytics.
    - Monitor app stability with real-time crash reports from Firebase Crashlytics.

5. **Firebase Security**:
    - Robust security features ensuring data privacy and integrity.
    - Defined security rules for databases, storage, and other services ensuring authorized access.

## Getting Started

Follow these steps to get `Type21` running on your local machine for development and testing purposes.

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

4. Ensure you've set up Firebase authentication for your Flutter app. Refer to Firebase documentation for a step-by-step guide.

### Running the App

Once you've set up the environment and installed all dependencies, run the following command:

```bash
flutter run
```

## Built With

- **Flutter**
- **Firebase**
- **Google Maps Flutter Plugin**

## Contributing

Contributions are what make the open-source community such an inspiring place to learn, inspire, and create. Any contributions you make to `Type21` are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---
