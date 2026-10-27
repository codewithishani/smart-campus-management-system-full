from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Student
from schemas.student import StudentCreate, StudentResponse


router = APIRouter(
    prefix="/students",
    tags=["Students"],
)


# ============================================================
# GET ALL STUDENTS
# Returns all students from the database.
# ============================================================

@router.get("/", response_model=list[StudentResponse])
def get_students(db: Session = Depends(get_db)):
    students = db.query(Student).all()

    return students


# ============================================================
# GET ONE STUDENT
# Returns one student using the student ID.
# Example: /students/1
# ============================================================

@router.get("/{student_id}", response_model=StudentResponse)
def get_student(
    student_id: int,
    db: Session = Depends(get_db),
):
    student = db.query(Student).filter(
        Student.student_id == student_id
    ).first()

    if student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    return student


# ============================================================
# CREATE STUDENT
# Adds a new student to the database.
# ============================================================

@router.post("/", response_model=StudentResponse)
def create_student(
    student: StudentCreate,
    db: Session = Depends(get_db),
):
    new_student = Student(
        user_id=student.user_id,
        roll_no=student.roll_no,
        name=student.name,
        email=student.email,
        phone=student.phone,
        department_id=student.department_id,
        course_id=student.course_id,
        semester=student.semester,
        address=student.address,
    )

    db.add(new_student)
    db.commit()
    db.refresh(new_student)

    return new_student


# ============================================================
# UPDATE STUDENT
# Updates an existing student using the student ID.
# ============================================================

@router.put("/{student_id}", response_model=StudentResponse)
def update_student(
    student_id: int,
    student: StudentCreate,
    db: Session = Depends(get_db),
):
    existing_student = db.query(Student).filter(
        Student.student_id == student_id
    ).first()

    if existing_student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    existing_student.user_id = student.user_id
    existing_student.roll_no = student.roll_no
    existing_student.name = student.name
    existing_student.email = student.email
    existing_student.phone = student.phone
    existing_student.department_id = student.department_id
    existing_student.course_id = student.course_id
    existing_student.semester = student.semester
    existing_student.address = student.address

    db.commit()
    db.refresh(existing_student)

    return existing_student


# ============================================================
# DELETE STUDENT
# Deletes an existing student using the student ID.
# ============================================================

@router.delete("/{student_id}")
def delete_student(
    student_id: int,
    db: Session = Depends(get_db),
):
    existing_student = db.query(Student).filter(
        Student.student_id == student_id
    ).first()

    if existing_student is None:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    db.delete(existing_student)
    db.commit()

    return {
        "message": "Student deleted successfully",
        "student_id": student_id,
    }