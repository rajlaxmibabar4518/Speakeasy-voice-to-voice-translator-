# 🎙️ Speakeasy – Voice-to-Voice Translator App

Speakeasy is a mobile application built using Flutter that enables real-time voice-to-voice translation. The app converts speech into text, translates it into another language, and provides spoken output, supporting both offline and online translation modes.

---

## 🚀 Features

* 🎤 **Speech-to-Text**: Converts user voice input into text
* 🌍 **Multi-language Translation**: Supports 20+ Indian languages
* 📶 **Offline Translation**: Uses Google ML Kit (English, Hindi, Marathi)
* 🌐 **Online Translation**: Uses APIs (Google, LibreTranslate, MyMemory)
* 🔊 **Text-to-Speech (TTS)**: Speaks translated output
* 👤 **Google Authentication**: Secure login using Firebase
* 🕒 **Translation History**: Stores user translations
* 💾 **Local Storage**: Uses Hive for caching and settings
* 🌗 **Dark/Light Mode**: User-selectable themes
* 🔊 **Adjustable Volume**: Control TTS output

---

## 🛠 Tech Stack

* **Frontend**: Flutter (Dart)
* **Authentication**: Firebase Authentication (Google Sign-In)
* **Database**: Hive (Local Storage)
* **Speech Recognition**: speech_to_text
* **Text-to-Speech**: flutter_tts
* **Offline Translation**: google_mlkit_translation
* **Online Translation**: HTTP APIs (Google Translate, LibreTranslate, MyMemory)
* **Utilities**: connectivity_plus, permission_handler

---

## ⚙️ How It Works

1. User speaks into the microphone 🎙️
2. App converts speech → text using device speech model
3. Text is translated:

   * Offline using ML Kit (if available)
   * Online using APIs (if internet is available)
4. Translated text is displayed
5. App converts text → voice using TTS 🔊

---

## 📲 Installation

1. Clone the repository:

```bash
git clone https://github.com/rajlaxmibabar4518/Speakeasy-voice-to-voice-translator-.git
```

2. Navigate to the project folder:

```bash
cd Speakeasy-voice-to-voice-translator-
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

---

## 🔐 Firebase Setup

This project uses Firebase for authentication.

To run the project properly:

* Add your own `google-services.json` file in `android/app/`
* Enable Google Sign-In in Firebase Console


## 📂 Project Structure

lib/ - Main application code
assets/ - Images and resources
android/ - Android configuration
ios/ - iOS configuration

---

## 👩‍💻 Author

**Rajlaxmi Babar**

---

## 📄 License

This project is for educational purposes.
