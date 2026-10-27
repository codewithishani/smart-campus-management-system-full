🎓 Smart Campus Management System

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Status-Academic%20Project-blue?style=for-the-badge" alt="Academic Project" />
</p><p align="center">
  <b>✨ A centralized platform for smarter campus management ✨</b>
  <br />
  Manage campus information, academic activities, and communication through one application.
</p>---

🌟 About the Project

Smart Campus Management System is an academic project designed to simplify campus-related activities through a centralized digital platform.

The project combines a Flutter frontend, a FastAPI backend, and a MySQL database to organize campus information and support communication between different user roles.

🚀 Key Features

- 🔐 User Authentication — Login and role-based navigation.
- 🧑‍💼 Admin Management — Manage campus-related records.
- 👩‍🏫 Faculty Module — Access faculty-oriented academic features.
- 🎓 Student Module — View relevant academic information.
- 👨‍👩‍👧 Parent Module — Access linked student information.
- 📅 Attendance & Timetable — Organize academic schedules and attendance.
- 📝 Assignments — Access assignment-related information.
- 📊 Examinations & Results — View examination and result information.
- 📢 Notices & Events — Keep track of campus announcements.
- 💬 Complaint Management — Support campus-related complaint handling.

«Note: Available features depend on the current implementation of the project.»

🛠️ Tech Stack

Technology| Purpose
📱 Flutter| Frontend application
⚡ FastAPI| Backend REST API
🐬 MySQL| Relational database
🐍 Python| Backend development
🔗 SQLAlchemy| Database interaction

🏗️ Project Architecture

Smart Campus Management System
             |
      Flutter Frontend
             |
        FastAPI Backend
             |
        MySQL Database

📂 Project Structure

smart_campus_app/
├── android/
├── lib/
│   ├── screens/
│   └── services/
├── backend/
│   ├── routers/
│   ├── models.py
│   ├── database.py
│   └── main.py
├── assets/
├── pubspec.yaml
├── README.md
└── .gitignore

Folder names may vary depending on the final project structure.

⚙️ Getting Started

Prerequisites

Install the following tools:

- Flutter SDK
- Python 3
- MySQL Server
- Git

1️⃣ Clone the Repository

git clone https://github.com/codewithishani/smart-campus-management-system-full.git
cd smart-campus-management-system-full

2️⃣ Configure the Backend

cd backend
python -m venv .venv

Activate the environment on Windows PowerShell:

.\.venv\Scripts\Activate.ps1

Install the backend dependencies:

pip install -r requirements.txt

Configure the required environment variables for your local MySQL database and application secret before starting the backend. Do not commit your ".env" file or real credentials.

3️⃣ Start the Backend

uvicorn main:app --reload

When configured correctly, the API documentation is generally available at:

"http://127.0.0.1:8000/docs"

4️⃣ Run the Flutter Application

Open a separate terminal in the project root:

flutter pub get
flutter run

«⚠️ Follow the project's actual database setup and configuration requirements. The commands above may need adjustment to match your environment.»

🖼️ Screenshots

<img width="1918" height="912" alt="image" src="https://github.com/user-attachments/assets/b5a07c65-a2fe-4435-b15c-ea10391dd814" />

🔒 Security & Privacy

- Never publish database passwords, API keys, or application secrets.
- Do not upload real student records or private submissions.
- Keep environment files and local configuration out of version control.
- Use sample data when demonstrating the project publicly.

🎯 Project Objectives

- Digitize campus-related workflows.
- Organize academic information in one place.
- Improve access to information for different user roles.
- Practice frontend, backend, and database integration.

👩‍💻 Author

CodeWithIshani

GitHub: "@codewithishani" (https://github.com/codewithishani)

📌 Future Enhancements

- 🔔 Push notifications
- 📈 Advanced analytics and reports
- 📱 Improved mobile experience
- 🔐 Enhanced authentication and access control

---

<p align="center">
  ⭐ If you find this project interesting, consider giving the repository a star!
  <br />
  💙 Built as an academic software development project.
</p>
---

<p align="center">
  🎓 <b>CAPSTONE PROJECT</b>
  <br />
  <b>Government Polytechnic, Pune (GPP)</b>
  <br />
  📅 Academic Year 2026–2027
  <br /><br />
  ✨ Smart Campus Management System ✨
  <br />
  💙 Developed as part of the academic capstone project.
</p>
