# Asset Castle 🏰

**Asset Castle** is a modern, enterprise-grade Flutter application designed for seamless IT Asset and Employee Management. Built with a clean architecture and Riverpod for robust state management, this application enables organizations to track hardware, assign assets to employees, generate QR codes, and monitor complete asset lifecycles in real-time.

<p align="center">
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/e17d84f2-f122-4ef8-ae6a-92eb3b8314dd" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/4392e7bf-a5c6-417d-963f-6b0a924aa9f1" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/e2160882-440e-49f2-a166-4dbab8a1883c" />
  </p>
<p align="center">
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/4a6bd141-1641-45ac-9831-4ce7c62c6298" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/b56121c8-b4b1-4795-82f9-748599a890ab" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/564dea0f-0cf2-4a08-a9b0-c76278e9dc87" />
  </p>
<p align="center">
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/96ba481f-8fe7-4020-bb66-247cb0c47780" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/d3f1d414-1ebf-4d3f-8d72-f9ac4dcea2b1" />
     <img width="243" height="527" alt="image" src="https://github.com/user-attachments/assets/57291a2e-1da1-4edd-b671-d5970a25176b" />
</p>

---

## 🔒 Legal & Copyright Notice
**© 2026 Aayush. All Rights Reserved.**
This repository and its entire source code are the proprietary property of Aayush. **No permission is granted** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of this software. You are strictly prohibited from rebranding, renaming, or claiming ownership of this project. See the [LICENSE](LICENSE) file for more legal details.

---

## 🌟 Key Features

### 💻 Asset Management
*   **Comprehensive Tracking:** Add, edit, and track the status of IT assets (Laptops, Monitors, Phones, etc.).
*   **Real-time Assignments:** Assign and unassign assets to specific employees with instant UI updates.
*   **Audit History:** Complete immutable history logs (created, updated, assigned, retired) for every asset.
*   **QR Code Generation:** Automatically generates a unique QR code for every asset for easy physical tracking and sharing.
*   **Image Storage:** Uses Cloudinary for highly optimized, zero-cost asset image hosting.

### 👥 Employee Management
*   **Profile Management:** Add employees, assign departments/designations, and upload profile pictures.
*   **Asset Linkage:** Instantly view how many and which assets are currently assigned to an employee.

### 📊 Dynamic Dashboard
*   **Real-time Analytics:** Uses Firestore Streams to provide live counters for Total Assets, Active, Assigned, and Retired states.
*   **Visual Distributions:** Dynamic Pie and Bar charts for Category and Department distributions using `fl_chart`.

### 🛡️ Secure & Scalable Architecture
*   **Clean Architecture:** Separation of UI, Domain, and Data layers.
*   **State Management:** Powered by `flutter_riverpod` and `riverpod_annotation` for predictive and reactive state flows.
*   **Backend integration:** Fully integrated with Firebase Authentication and Firestore Database.

---

## 🚀 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** Riverpod 3.x (`flutter_riverpod`)
*   **Backend (BaaS):** Firebase (Auth, Firestore)
*   **Media Storage:** Cloudinary
*   **Key Packages:**
    *   `fl_chart` (Data Visualization)
    *   `qr_flutter` (QR Code Generation)
    *   `image_picker` & `cloudinary_public` (Media Uploads)
    *   `go_router` (Navigation)

---

## 🛠️ Setup Instructions

**⚠️ IMPORTANT NOTE:** For security reasons, the Firebase configuration files and environment secrets are **excluded** from this repository. To run this project locally, you must provide your own Firebase and Cloudinary credentials.

### Prerequisites
*   Flutter SDK (^3.11.1)
*   Dart SDK
*   A Firebase Project
*   A Cloudinary Account

### 1. Clone the repository
```bash
git clone <your-github-repo-url>
cd asset_castle
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase
Since `google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` are ignored, you must configure Firebase manually:
1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Firestore Database** and **Authentication** (Email/Password).
3. Run the FlutterFire CLI to generate your config:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=your-firebase-project-id
```

### 4. Setup Firestore Indexes
The real-time history logs require a Composite Index in Firestore.
1. Go to Firebase Console -> Firestore Database -> Indexes.
2. Add a new Index for collection `asset_logs`.
3. Fields: `assetId` (Ascending) and `timestamp` (Descending).

### 5. Configure Cloudinary
Images are uploaded to Cloudinary. You must add your own API keys.
1. Open `lib/data/services/storage_service.dart`.
2. Replace `_cloudName` and `_uploadPreset` with your own Cloudinary Unsigned Upload Preset credentials.

### 6. Run the App
```bash
flutter run
```

---

## 📁 Project Structure

```text
lib/
├── core/               # App-wide constants, themes, styles, and helpers
├── data/               # Repositories, Models, and External Services (Firebase/Cloudinary)
├── domain/             # Enums and core business logic definitions
└── presentation/       # Feature-based UI architecture
    ├── assets/         # Asset tracking screens and widgets
    ├── auth/           # Login and Registration flows
    ├── dashboard/      # Real-time analytics dashboard
    ├── employees/      # Employee management screens
    └── settings/       # Theme toggles and app configurations
```

---

*Designed and Developed by Aayush.*
