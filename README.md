# 📝 TaskMate - Flutter Todo App

TaskMate is a Flutter-based Todo application developed as a learning project to practice building real-world mobile apps using Flutter.
The app helps users manage daily tasks efficiently with categories, priorities, due dates, and local notifications.

This project focuses on clean UI, local data storage, and notification handling, making it ideal for understanding core Flutter concepts.

## ✨ Features

### 🎯 Core Features
- **Task Management**: Add, edit, delete, and complete tasks
- **Task Categories**: Organize tasks by Work, Personal, Shopping, Health, and Other
- **Priority Levels**: Set task priority (High, Medium, Low) with color coding
- **Due Dates & Times**: Schedule tasks with specific date and time reminders
- **Smart Notifications**: Get timely reminders for your scheduled tasks

### 🎨 User Experience
- **Modern UI**: Clean, intuitive interface with gradient designs
- **Responsive Design**: Works perfectly on all screen sizes
- **Smooth Animations**: Confetti celebrations and fluid transitions
- **Task Sorting**: Automatic sorting by importance and due dates
- **Completed Tasks**: Separate section for completed tasks with clear option

### 🔔 Local Notifications
- Scheduled local notifications for task reminders
- Works even when the app is closed
- Time-zone aware notification scheduling
- Proper runtime permission handling

## 🛠 Technologies Used

- **Flutter 3.32.4** - Cross-platform UI framework
- **Dart 3.8.1** - Programming language
- **flutter_local_notifications** - Local notification system
- **shared_preferences** - Local data persistence
- **confetti** - Celebration animations
- **awesome_dialog** - Beautiful dialog boxes
- **permission_handler** - Runtime permissions
- **timezone** - Time zone handling

## 📱 Screenshots

<img width="953" height="552" alt="todo-app1" src="https://github.com/user-attachments/assets/1c8d33ab-7d78-408d-bfb4-dd6e79176203" />

<img width="953" height="552" alt="todo-app2" src="https://github.com/user-attachments/assets/d795ea75-43fc-40ed-8a07-ec2ac1db86f1" />

<img width="313" height="552" alt="todo-app3" src="https://github.com/user-attachments/assets/d89c67c5-c3fc-44e5-9d01-eb12058acca3" />

### Main Features:
- Home screen with task list
- Add/Edit task dialog with all options
- Category and priority selection
- Date and time pickers
- Completed tasks section

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── models/
│   └── task.dart              # Task data model
├── services/
│   ├── notification_service.dart # Notification management
│   └── task_service.dart      # Task persistence
├── screens/
│   └── todo_screen.dart       # Main UI screen
├── widgets/
│   └── task_item.dart         # Reusable task widget
└── main.dart                 # App entry point
```

## 🔧 Configuration

### Android Permissions
The app requires these permissions (automatically requested):
- `POST_NOTIFICATIONS` - Show notifications
- `SCHEDULE_EXACT_ALARM` - Precise alarm scheduling
- `RECEIVE_BOOT_COMPLETED` - Boot receiver for notifications

### 🎯 Learning Outcomes

This project helped me understand and practice:

- Flutter widget structure and UI design
- State management using setState
- Local storage using SharedPreferences
- Scheduling and managing local notifications
- Permission handling in Android
- Writing clean and reusable Flutter code

## 🐛 Known Limitations

- Data is stored locally (no cloud sync)
- Notifications may be affected by device battery optimization
- Designed mainly for learning purposes

## 🚧 Future Improvements

- Firebase authentication and cloud storage
- State management using Provider or Riverpod
- Task search and filtering
- Dark mode support
- Web-specific UI improvements

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Keerthana** - *Flutter Developer*

- Email: keerthana010804@gmail.com

**⭐ This project was built as part of my Flutter learning journey.**
**⭐ If you like this project, please give it a star on GitHub!**

Made with ❤️ using Flutter
