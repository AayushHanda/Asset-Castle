# Asset Castle - Asset Management App

<p align="center">
  <img src="assets/images/app_logo.png" width="100" alt="Asset Castle Logo" />
</p>

<p align="center">
  <b>**Asset Castle** is a modern, enterprise-grade Flutter application designed for seamless IT Asset and Employee Management.</b><br/>
  Built with a clean architecture and Riverpod for robust state management, this application enables organizations to track hardware, assign assets to employees, generate QR codes, and monitor complete asset lifecycles in real-time.
</p>
 

<p align="center">
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/421fe8ee-1b57-4ac1-8446-72f0ada76f5e" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/5499f7d9-fc9d-4a2f-8fe5-59d94a0763d0" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/cd83d427-21e3-43ba-b1ad-c33649b79b6b" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/da69fa6d-a6f0-4614-931e-880d31c03b44" />
</p>

<p align="center">
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/f1f8f15a-c612-4fae-8cc4-7e6c55f0c4ec" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/76ce9b8d-3584-4797-90dd-a559b9139819" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/fcae29eb-b2bc-4ac1-9b90-f8cf2ce7a49a" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/1d679fb8-1b4b-40e9-8985-280812329084" />
</p>

<p align="center">
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/67128cff-0587-4a15-bee6-8e23c9f3e6b0" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/c659a853-5d64-4239-8087-5a2813e93e27" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/c171bb43-a90f-4e16-9e03-ee9d6817cb7b" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/26788ecf-513a-45d4-a73f-f3d3eb3f9bbb" />
</p>

<p align="center">
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/86b8193b-880b-4214-b301-39d60c7891d7" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/602008cf-0c5a-4e4f-ada4-04b929669eb9" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/a8041afb-ee6c-4df1-bedf-1b0041d8a519" />
  <img width="20%" alt="image" src="https://github.com/user-attachments/assets/a67c98ae-a638-4167-81a8-921226564cfd" />
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
