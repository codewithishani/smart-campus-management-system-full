from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    DECIMAL,
    ForeignKey,
    Integer,
    String,
    Text,
    Time,
)
from sqlalchemy.orm import relationship
from database import Base


class Role(Base):
    __tablename__ = "roles"

    role_id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String(50), nullable=False, unique=True)
    description = Column(String(255))

    users = relationship("User", back_populates="role")


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    phone = Column(String(15))
    role_id = Column(Integer, ForeignKey("roles.role_id"), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime)

    role = relationship("Role", back_populates="users")
    notices = relationship("Notice", back_populates="user")
    events = relationship("Event", back_populates="creator")
    notifications = relationship("Notification", back_populates="user")
    leave_requests = relationship(
        "LeaveRequest",
        foreign_keys="LeaveRequest.user_id",
        back_populates="user",
    )
    approved_leaves = relationship(
        "LeaveRequest",
        foreign_keys="LeaveRequest.approved_by",
        back_populates="approver",
    )
    assigned_complaints = relationship(
        "Complaint",
        foreign_keys="Complaint.assigned_to",
        back_populates="assigned_user",
    )
    student_profile = relationship(
        "Student",
        back_populates="user",
        uselist=False,
    )
    faculty_profile = relationship(
        "Faculty",
        back_populates="user",
        uselist=False,
    )
    parent_profile = relationship(
        "Parent",
        back_populates="user",
        uselist=False,
    )


class Department(Base):
    __tablename__ = "departments"

    department_id = Column(Integer, primary_key=True, index=True)
    department_name = Column(String(100), nullable=False)
    description = Column(String(255))
    hod_name = Column(String(100))
    created_at = Column(DateTime)

    students = relationship("Student", back_populates="department")
    faculty = relationship("Faculty", back_populates="department")
    courses = relationship("Course", back_populates="department")


class Course(Base):
    __tablename__ = "courses"

    course_id = Column(Integer, primary_key=True, index=True)
    department_id = Column(
        Integer,
        ForeignKey("departments.department_id"),
        nullable=False,
    )
    course_name = Column(String(100), nullable=False)
    course_code = Column(String(20), nullable=False, unique=True)
    duration = Column(Integer)
    description = Column(String(255))
    created_at = Column(DateTime)

    department = relationship("Department", back_populates="courses")
    students = relationship("Student", back_populates="course")
    subjects = relationship("Subject", back_populates="course")
    classes = relationship("ClassRoom", back_populates="course")
    exams = relationship("Exam", back_populates="course")


class Student(Base):
    __tablename__ = "students"

    student_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
        unique=True,
    )
    roll_no = Column(String(20), nullable=False, unique=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100))
    phone = Column(String(15))
    department_id = Column(
        Integer,
        ForeignKey("departments.department_id"),
        nullable=False,
    )
    course_id = Column(
        Integer,
        ForeignKey("courses.course_id"),
        nullable=False,
    )
    semester = Column(Integer)
    address = Column(String(255))

    user = relationship("User", back_populates="student_profile")
    department = relationship("Department", back_populates="students")
    course = relationship("Course", back_populates="students")
    attendance = relationship("Attendance", back_populates="student")
    submissions = relationship("Submission", back_populates="student")
    results = relationship("Result", back_populates="student")
    complaints = relationship(
        "Complaint",
        foreign_keys="Complaint.student_id",
        back_populates="student",
    )
    parent_links = relationship("ParentStudent", back_populates="student")


class Faculty(Base):
    __tablename__ = "faculty"

    faculty_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
        unique=True,
    )
    employee_id = Column(String(20), nullable=False, unique=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100))
    phone = Column(String(15))
    department_id = Column(
        Integer,
        ForeignKey("departments.department_id"),
        nullable=False,
    )
    designation = Column(String(100))

    user = relationship("User", back_populates="faculty_profile")
    department = relationship("Department", back_populates="faculty")
    classes = relationship(
        "ClassRoom",
        back_populates="class_teacher",
    )
    timetable_entries = relationship(
        "Timetable",
        back_populates="faculty",
    )
    attendance = relationship("Attendance", back_populates="faculty")
    notes = relationship("Note", back_populates="faculty")
    assignments = relationship("Assignment", back_populates="faculty")


class Parent(Base):
    __tablename__ = "parents"

    parent_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
        unique=True,
    )
    name = Column(String(100), nullable=False)
    email = Column(String(100))
    phone = Column(String(15))
    address = Column(String(255))

    user = relationship("User", back_populates="parent_profile")
    student_links = relationship(
        "ParentStudent",
        back_populates="parent",
    )


class Subject(Base):
    __tablename__ = "subjects"

    subject_id = Column(Integer, primary_key=True, index=True)
    course_id = Column(
        Integer,
        ForeignKey("courses.course_id"),
        nullable=False,
    )
    subject_name = Column(String(100), nullable=False)
    subject_code = Column(String(20), nullable=False, unique=True)
    semester = Column(Integer)
    credits = Column(Integer)
    description = Column(String(255))

    course = relationship("Course", back_populates="subjects")
    timetable_entries = relationship(
        "Timetable",
        back_populates="subject",
    )
    attendance = relationship("Attendance", back_populates="subject")
    notes = relationship("Note", back_populates="subject")
    assignments = relationship(
        "Assignment",
        back_populates="subject",
    )
    exams = relationship("Exam", back_populates="subject")
    results = relationship("Result", back_populates="subject")


class ClassRoom(Base):
    __tablename__ = "classes"

    class_id = Column(Integer, primary_key=True, index=True)
    course_id = Column(
        Integer,
        ForeignKey("courses.course_id"),
        nullable=False,
    )
    class_name = Column(String(50), nullable=False)
    semester = Column(Integer)
    academic_year = Column(String(20))
    class_teacher_id = Column(
        Integer,
        ForeignKey("faculty.faculty_id"),
    )
    created_at = Column(DateTime)

    course = relationship("Course", back_populates="classes")
    class_teacher = relationship(
        "Faculty",
        back_populates="classes",
    )
    timetable_entries = relationship(
        "Timetable",
        back_populates="class_room",
    )
    notes = relationship("Note", back_populates="class_room")
    assignments = relationship(
        "Assignment",
        back_populates="class_room",
    )
    exams = relationship("Exam", back_populates="class_room")


class Timetable(Base):
    __tablename__ = "timetable"

    timetable_id = Column(Integer, primary_key=True, index=True)
    class_id = Column(
        Integer,
        ForeignKey("classes.class_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    faculty_id = Column(
        Integer,
        ForeignKey("faculty.faculty_id"),
        nullable=False,
    )
    day = Column(String(15), nullable=False)
    start_time = Column(Time)
    end_time = Column(Time)
    room_no = Column(String(20))

    class_room = relationship(
        "ClassRoom",
        back_populates="timetable_entries",
    )
    subject = relationship(
        "Subject",
        back_populates="timetable_entries",
    )
    faculty = relationship(
        "Faculty",
        back_populates="timetable_entries",
    )


class Attendance(Base):
    __tablename__ = "attendance"

    attendance_id = Column(Integer, primary_key=True, index=True)
    student_id = Column(
        Integer,
        ForeignKey("students.student_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    faculty_id = Column(
        Integer,
        ForeignKey("faculty.faculty_id"),
        nullable=False,
    )
    attendance_date = Column(Date, nullable=False)
    status = Column(String(10), nullable=False)
    remarks = Column(String(255))

    student = relationship("Student", back_populates="attendance")
    subject = relationship("Subject", back_populates="attendance")
    faculty = relationship("Faculty", back_populates="attendance")


class Note(Base):
    __tablename__ = "notes"

    note_id = Column(Integer, primary_key=True, index=True)
    faculty_id = Column(
        Integer,
        ForeignKey("faculty.faculty_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    class_id = Column(
        Integer,
        ForeignKey("classes.class_id"),
        nullable=False,
    )
    title = Column(String(150), nullable=False)
    description = Column(String(255))
    file_url = Column(String(255))
    uploaded_at = Column(DateTime)

    faculty = relationship("Faculty", back_populates="notes")
    subject = relationship("Subject", back_populates="notes")
    class_room = relationship("ClassRoom", back_populates="notes")


class Assignment(Base):
    __tablename__ = "assignments"

    assignment_id = Column(Integer, primary_key=True, index=True)
    faculty_id = Column(
        Integer,
        ForeignKey("faculty.faculty_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    class_id = Column(
        Integer,
        ForeignKey("classes.class_id"),
        nullable=False,
    )
    title = Column(String(150), nullable=False)
    description = Column(Text)
    due_date = Column(Date)
    created_at = Column(DateTime)

    faculty = relationship("Faculty", back_populates="assignments")
    subject = relationship("Subject", back_populates="assignments")
    class_room = relationship(
        "ClassRoom",
        back_populates="assignments",
    )
    submissions = relationship(
        "Submission",
        back_populates="assignment",
    )


class Submission(Base):
    __tablename__ = "submissions"

    submission_id = Column(Integer, primary_key=True, index=True)
    assignment_id = Column(
        Integer,
        ForeignKey("assignments.assignment_id"),
        nullable=False,
    )
    student_id = Column(
        Integer,
        ForeignKey("students.student_id"),
        nullable=False,
    )
    file_url = Column(String(255))
    submission_date = Column(DateTime)
    status = Column(String(20))
    marks = Column(DECIMAL(5, 2))
    feedback = Column(Text)

    assignment = relationship(
        "Assignment",
        back_populates="submissions",
    )
    student = relationship(
        "Student",
        back_populates="submissions",
    )


class Exam(Base):
    __tablename__ = "exams"

    exam_id = Column(Integer, primary_key=True, index=True)
    course_id = Column(
        Integer,
        ForeignKey("courses.course_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    class_id = Column(
        Integer,
        ForeignKey("classes.class_id"),
        nullable=False,
    )
    exam_name = Column(String(100), nullable=False)
    exam_date = Column(Date)
    start_time = Column(Time)
    end_time = Column(Time)
    room_no = Column(String(20))

    course = relationship("Course", back_populates="exams")
    subject = relationship("Subject", back_populates="exams")
    class_room = relationship("ClassRoom", back_populates="exams")
    results = relationship("Result", back_populates="exam")


class Result(Base):
    __tablename__ = "results"

    result_id = Column(Integer, primary_key=True, index=True)
    exam_id = Column(
        Integer,
        ForeignKey("exams.exam_id"),
        nullable=False,
    )
    student_id = Column(
        Integer,
        ForeignKey("students.student_id"),
        nullable=False,
    )
    subject_id = Column(
        Integer,
        ForeignKey("subjects.subject_id"),
        nullable=False,
    )
    marks_obtained = Column(DECIMAL(5, 2))
    total_marks = Column(DECIMAL(5, 2))
    grade = Column(String(5))
    result_status = Column(String(20))
    remarks = Column(String(255))
    created_at = Column(DateTime)

    exam = relationship("Exam", back_populates="results")
    student = relationship("Student", back_populates="results")
    subject = relationship("Subject", back_populates="results")


class Notice(Base):
    __tablename__ = "notices"

    notice_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
    )
    title = Column(String(150), nullable=False)
    description = Column(Text)
    notice_type = Column(String(50))
    target_role = Column(String(30))
    publish_date = Column(Date)
    expiry_date = Column(Date)
    created_at = Column(DateTime)
    status = Column(String(20))

    user = relationship("User", back_populates="notices")


class Event(Base):
    __tablename__ = "events"

    event_id = Column(Integer, primary_key=True, index=True)
    created_by = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
    )
    title = Column(String(150), nullable=False)
    description = Column(Text)
    event_type = Column(String(50))
    event_date = Column(Date)
    start_time = Column(Time)
    end_time = Column(Time)
    venue = Column(String(150))
    target_role = Column(String(30))
    status = Column(String(20))
    created_at = Column(DateTime)

    creator = relationship("User", back_populates="events")


class Complaint(Base):
    __tablename__ = "complaints"

    complaint_id = Column(Integer, primary_key=True, index=True)
    student_id = Column(
        Integer,
        ForeignKey("students.student_id"),
        nullable=False,
    )
    assigned_to = Column(
        Integer,
        ForeignKey("users.user_id"),
    )
    title = Column(String(150), nullable=False)
    description = Column(Text)
    complaint_type = Column(String(50))
    priority = Column(String(20))
    status = Column(String(20))
    submitted_at = Column(DateTime)
    resolved_at = Column(DateTime)

    student = relationship(
        "Student",
        foreign_keys=[student_id],
        back_populates="complaints",
    )
    assigned_user = relationship(
        "User",
        foreign_keys=[assigned_to],
        back_populates="assigned_complaints",
    )


class Notification(Base):
    __tablename__ = "notifications"

    notification_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
    )
    title = Column(String(150), nullable=False)
    message = Column(Text)
    notification_type = Column(String(50))
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime)

    user = relationship("User", back_populates="notifications")


class LeaveRequest(Base):
    __tablename__ = "leave_requests"

    leave_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id"),
        nullable=False,
    )
    from_date = Column(Date)
    to_date = Column(Date)
    reason = Column(Text)
    leave_type = Column(String(30))
    status = Column(String(20))
    approved_by = Column(
        Integer,
        ForeignKey("users.user_id"),
    )
    remarks = Column(String(255))
    requested_at = Column(DateTime)
    updated_at = Column(DateTime)

    user = relationship(
        "User",
        foreign_keys=[user_id],
        back_populates="leave_requests",
    )
    approver = relationship(
        "User",
        foreign_keys=[approved_by],
        back_populates="approved_leaves",
    )


class ParentStudent(Base):
    __tablename__ = "parent_student"

    parent_student_id = Column(
        Integer,
        primary_key=True,
        index=True,
    )
    parent_id = Column(
        Integer,
        ForeignKey("parents.parent_id"),
        nullable=False,
    )
    student_id = Column(
        Integer,
        ForeignKey("students.student_id"),
        nullable=False,
    )
    relationship_type = Column(String(30))
    is_primary = Column(Boolean, default=False)
    created_at = Column(DateTime)

    parent = relationship(
        "Parent",
        back_populates="student_links",
    )

    student = relationship(
        "Student",
        back_populates="parent_links",
    )