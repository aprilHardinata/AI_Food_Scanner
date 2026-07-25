# AI Food Scanner (Mobile App) 📱🍔

This repository contains the **Frontend** of the AI Food Scanner system, a mobile application built with **Flutter** that allows users to scan food and receive AI-powered analysis.

This application relies entirely on a Backend server for its AI processing capabilities.
🔗 **Backend Repository:** [AI Agent (Python)](https://github.com/aprilHardinata/Ai_agent)

---

## 🛠️ Tech Stack
- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** Dart

## ⚙️ Setup & Installation

Follow these steps to run the mobile application on your device or emulator:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/aprilHardinata/AI_Food_Scanner.git
   cd AI_Food_Scanner
   ```

2. **Install Flutter Dependencies:**
   Run the following command to fetch all required packages:
   ```bash
   flutter pub get
   ```

3. **Configure Backend URL (Important!):**
   Make sure to update the API Base URL / Endpoint in your codebase (usually inside the network or HTTP request configuration file) to point to your local Backend server.
   - If running the Python server on the same machine and testing with an **Android Emulator**, use the IP address `http://10.0.2.2:PORT`.
   - If using a physical device, use your computer's local WiFi IP address (e.g., `http://192.168.1.x:PORT`).

## 🚀 Running the App

Ensure that the [Python Backend](https://github.com/aprilHardinata/Ai_agent) is **up and running**.

Then, make sure your emulator is launched or your physical device is connected, and run:

```bash
flutter run
```

The app will build and open directly on your screen. Happy coding!
