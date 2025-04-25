# Final-Year-Project
# CLoud-Integrated Air Purification System

A Flutter-based Android application developed for **Arklite Speciality Lamps Pvt. Ltd.** that monitors and controls UV lamps in HVAC systems. It integrates IoT (ESP32) and cloud services (ThinkSpeak & Firebase) for real-time monitoring, working hour tracking, error detection, and on/off control of UV lamps.


##  Features

-  **Secure Login** using Firebase Authentication
-  **Real-Time Lamp Status** (ON/OFF)
-  **Working Hours Display**
-  **Error Detection Alert** after 135 seconds of lamp being OFF
-  **Toggle Lamp ON/OFF** from the app
-  **Global State Management** using Provider
-  **Custom UI Dashboard** with individual lamp status


##  Folder Structure

lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── lamp_screen.dart
│   ├── login_screen.dart
│   └── signup_screen.dart
├── services/
│   ├── firebase_auth_service.dart
│   └── thingspeak_service.dart
├── utils/
│   └── lamp_state.dart
|   └──app_theme.dart
└── widgets/
    └── custom_button.dart
    └── lamp_tile.dart

**Setup Instructions**
Prerequisites
   
   Flutter SDK installed
   
   Android Studio or VS Code
   
   Firebase project setup
   
   ThinkSpeak channel and API key
   
   ESP32 connected and publishing data

**ESP32 Integration**
  
  Uses ESP32 with UV lamp circuit
  
  Publishes data to ThinkSpeak channel
  
  Controlled via public/private API keys
  
  Lamp ON/OFF status updated via HTTP GET/POST

**Dependencies:**
flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5
  http: ^1.3.0
  provider: ^6.0.0

**Future Scope:**
  
  PDF report generation for lamp history
  
  Multi-user roles and permissions
  
  Push notifications for errors
  
  Historical data analytics
