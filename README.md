# Storytelling Audio Application

This project is a storytelling audio application, developed as my senior thesis. It leverages Text-to-Speech technology to create a system that simplifies and reduces the cost of producing audio stories compared to traditional methods.

The system is composed of two main parts
* Admin Web Application: A platform for administrators to manage story content and synthesize speech.
* User Mobile Application: An app designed for users to browse, select, and listen to a library of audio stories.

### App Preview
| User Mobile Preview | Admin Web Preview |
|:---:|:---:|
| <img src="assets/images/mobile-preview.gif" alt="User Mobile Preview" height="250px"> | <img src="assets/images/web-preview.gif" alt="Admin Web Preview" height="240px"> |

### Features
#### User
* Listen to English audio stories with illustrations and Thai subtitles
* Save favorite stories for quick access
* Automatically saves your progress so you can continue listening from where you stopped
* Allow users to rate stories on a 1-5 star scale after completion

#### Admin
* Verify administrator privileges before allowing login
* Easily create, search, update, and delete story content
* Automatically synthesizes story content into an audio file
* A user-friendly GUI allows admins to apply SSML tags (e.g. changing pitch, emphasis, speed, etc.) by simply highlighting text, making it easy to create expressive audio without technical skills

### Tech Stack
* Flutter Framework / Dart Language
* Google Cloud Text-to-Speech API
* Firebase
* Visual Studio Code
* Android Studio

### Built by
1. Pitchaya Pimmahasiri - Responsible for mobile app development
2. Siriwan Singlor - Responsible for web app development
