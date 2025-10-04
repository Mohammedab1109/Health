# Health Events App

A Flutter application for creating and managing health and sports events. Users can create accounts, sign in, and create/join events.

## Features

- User authentication (Sign In/Sign Up)
- Firebase integration for authentication and data storage
- Modern Material Design UI
- Coming soon: Health and sports events creation and management

## Getting Started

### Prerequisites

- Flutter SDK installed (latest stable version recommended)
- Firebase project set up
- Android Studio/VS Code with Flutter plugins

### Setup

1. Clone the repository
   ```
   git clone https://github.com/Mohammedab1109/Health.git
   cd health
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android and iOS apps to your Firebase project
   - Download and place the configuration files:
     - Android: `google-services.json` into `android/app/`
     - iOS: `GoogleService-Info.plist` into `ios/Runner/`

4. Enable Authentication in Firebase Console
   - Go to Authentication > Sign-in method
   - Enable Email/Password authentication

5. Run the app
   ```
   flutter run
   ```

## Project Structure

- `lib/`
  - `main.dart` - Entry point for the application
  - `pages/` - Contains screen/page widgets
    - `sign_in_page.dart` - Sign in screen
    - `sign_up_page.dart` - Sign up screen
    - `home_page.dart` - Home screen after authentication
  - `services/` - Service classes
    - `auth_service.dart` - Firebase authentication handling
  - `widgets/` - Reusable widgets
    - `loading_indicator.dart` - Custom loading spinner widget

## Authentication Flow

1. When the app starts, it checks if the user is already signed in
2. If not signed in, the Sign In page is displayed
3. Users can navigate to Sign Up page to create a new account
4. After successful authentication, users are redirected to the Home page

## Contributing

1. Fork the repository
2. Create a new feature branch
3. Implement your changes
4. Create a pull request

## License

This project is licensed under the MIT License
