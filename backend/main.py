from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers.student import router as student_router
from routers.faculty import router as faculty_router
from routers.parent import router as parent_router
from routers.department import router as department_router
from routers.course import router as course_router
from routers.subject import router as subject_router
from routers.class_room import router as class_room_router
from routers.timetable import router as timetable_router
from routers.attendance import router as attendance_router
from routers.note import router as note_router
from routers.assignment import router as assignment_router
from routers.submission import router as submission_router
from routers.exam import router as exam_router
from routers.result import router as result_router
from routers.notice import router as notice_router
from routers.event import router as event_router
from routers.complaint import router as complaint_router
from routers.notification import router as notification_router
from routers.leave_request import router as leave_request_router
from routers.parent_student import router as parent_student_router
from routers.user import router as user_router
from routers.auth import router as auth_router


app = FastAPI(
    title="Smart Campus Management System",
    description="Backend API for Smart Campus Management System",
    version="1.0.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =========================
# ROUTERS
# =========================

app.include_router(auth_router)

app.include_router(student_router)
app.include_router(faculty_router)
app.include_router(parent_router)
app.include_router(department_router)
app.include_router(course_router)
app.include_router(subject_router)
app.include_router(class_room_router)
app.include_router(timetable_router)
app.include_router(attendance_router)
app.include_router(note_router)
app.include_router(assignment_router)
app.include_router(submission_router)
app.include_router(exam_router)
app.include_router(result_router)
app.include_router(notice_router)
app.include_router(event_router)
app.include_router(complaint_router)
app.include_router(notification_router)
app.include_router(leave_request_router)
app.include_router(parent_student_router)
app.include_router(user_router)


@app.get("/")
def home():
    return {
        "message": "Smart Campus Backend is running!",
        "status": "success",
    }