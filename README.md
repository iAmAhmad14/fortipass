# 🔐 FortiPass

FortiPass is a **secure and minimal password manager app** built with **Flutter** and **Firebase**.  
It allows users to safely store and manage confidential information — such as passwords, credit card details, ID cards, and secure notes — all in one encrypted and organized place.

---

## 🚀 Features

- 🔑 **Email/Password Authentication** (Firebase Auth)  
- 🗂️ **Organized Categories**
  - Passwords  
  - Secure Notes  
  - Credit Cards  
  - ID Cards
- ➕ Add, Edit, and Delete entries easily  
- ⭐ Mark items as Favorites  
- 🔍 Search and filter functionality  
- ☁️ Firebase Firestore for cloud data storage  
- 🧩 Simple, clean, and modern UI  
- 📱 Works on both Android and Web (Chrome)

---

## 🧰 Tech Stack

- **Frontend:** Flutter (Dart)  
- **Backend:** Firebase (Auth + Firestore)  
- **Cloud Configuration:** Firebase CLI (`flutterfire configure`)

---

## 🏗️ Project Setup

### 1️⃣ Prerequisites
Make sure you have installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Git](https://git-scm.com/)
- A Firebase project created on [Firebase Console](https://console.firebase.google.com)

---

### 2️⃣ Clone the Repository
```bash
git clone https://github.com/<your-username>/fortipass.git
cd fortipass
```

---

### 3️⃣ Install Dependencies
```bash
flutter pub get
```

---

### 4️⃣ Connect Firebase
Run the FlutterFire CLI to generate your Firebase configuration file:
```bash
flutterfire configure
```
This will create a file named:
```
lib/firebase_options.dart
```
> ⚠️ Note: The file `android/app/google-services.json` should **not** be public.  
> Add it manually from your Firebase Console.

---

### 5️⃣ Run the App
#### 🧩 For Android:
```bash
flutter run
```

#### 🌐 For Web:
```bash
flutter run -d chrome
```

---

## 🗃️ Folder Structure

```
lib/
 ┣ main.dart                 # Entry point
 ┣ firebase_options.dart     # Firebase config (auto-generated)
 ┣ screens/                  # All app screens (Home, Login, Add Entry, etc.)

```

---


## 🧠 Future Improvements

- Biometric authentication (fingerprint/face unlock)  
- Password generator  
- Encrypted local storage (Hive / SQLite)  
- Dark mode  


---

## 🪪 License

This project is open source and available under the [MIT License](LICENSE).
