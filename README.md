# Soocily — Social Media App (Flutter)

🚀 **Live Web App:** [soocily-affd3.web.app](https://soocily-affd3.web.app)  
📱 **Platforms:** Flutter Web & Mobile  
🛠️ **Status:** Personal Project (in development & experimentation)

---

## ✨ Overview

**Soocily** is a fully functional social media application I developed as a personal project to explore complex app architecture, advanced state management, and cross-platform development using **Flutter**. The app allows users to authenticate, create and interact with posts, follow others, manage profiles, and toggle between light and dark themes.

This project is not just about building an app, but also showcasing **software architecture best practices**, **scalable code organization**, and **real-world Flutter development techniques**.

---

## 🧠 Key Features & Technical Highlights

### 🧱 Architecture

- **Clean Architecture**

  - **Layered Structure**: Divided into `Data`, `Domain`, and `Presentation` layers for testability and separation of concerns.
  - **Repository Pattern** to abstract and manage data sources.

- **Feature-First Folder Structure**
  - Each domain feature is modularized (e.g., `post`, `auth`, `home`, `settings`).

### ⚙️ State Management

- **Bloc (Cubit) Pattern**

  - All user interactions and app state flows are managed using **Cubit** for simplicity and performance.
  - Custom `Cubit` and `State` classes for handling posts, themes, settings, etc.

- **Optimistic UI Updates**
  - Instant UI feedback while awaiting backend responses (e.g., post creation, following/unfollowing).

### 🔐 Authentication

- Firebase-based **email/password login**
- Persistent login state and secure navigation flows.

### 📷 Social Features

- **Posts** with comments
- **Follow/Unfollow** functionality
- **Profile Management** including image upload, bio/about section
- Light & Dark **Theme Switching**

### 🌐 Web Support

- Responsive design using `ConstrainedScaffold`
- Works on both **mobile and web** with Flutter's `--web-renderer html` for better image support

---

## 🛠️ Tech Stack

| Category         | Tech Used                                  |
| ---------------- | ------------------------------------------ |
| UI/UX            | Flutter, Material 3, Responsive Layout     |
| State Management | Bloc (Cubit), StreamBuilders               |
| Backend          | Firebase Auth, Firestore, Firebase Storage |
| Architecture     | Clean Architecture, Repository Pattern     |
| Media Handling   | Image Picker, Firebase Storage             |
| Web Deployment   | Firebase Hosting, HTML Renderer            |
| Dev Skills       | Debugging, Code Modularity, Git, CI-ready  |

---

## 📁 Project Structure (Highlights)

```
lib/
├── app.dart
├── main.dart
├── config/
├── features/
│   ├── auth/
│   ├── post/
│   ├── home/
│   ├── settings/
│   ├── theme/
│   └── profile/
└── responsive/
```

---

## 💡 Why I Built This

This project was an opportunity for me to:

- Practice **building scalable apps** with real-world features
- Deep dive into **Bloc** and Flutter's **web capabilities**
- Improve **UI/UX design** and mobile/web responsive design skills
- Showcase **clean code**, **modularity**, and **tech leadership potential**

---

## 🚧 Future Improvements

- Add unit and widget tests
- Implement post likes & comments in real-time
- Pagination & lazy loading for feed
- In-app notifications

---

## 📸 Screenshots

<table>
  <tr>
    <td><img src="public/img 1.png" width="200"/></td>
    <td><img src="public/img 2.png" width="200"/></td>
    <td><img src="public/img 3.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="public/img 4.png" width="200"/></td>
    <td><img src="public/img 5.png" width="200"/></td>
    <td><img src="public/img 6.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="public/img 7.png" width="200"/></td>
  </tr>
</table>

---

## 📬 Feedback & Contact

I’m always looking to grow as a developer. Feedback, suggestions, or collaborations are welcome!  
**Email:** [LinkedIn](https://www.linkedin.com/in/dileep2896/)
