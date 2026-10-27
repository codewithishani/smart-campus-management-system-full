from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Faculty
from schemas.faculty import FacultyCreate, FacultyResponse


router = APIRouter(
    prefix="/faculty",
    tags=["Faculty"],
)


@router.get("/", response_model=list[FacultyResponse])
def get_faculty(db: Session = Depends(get_db)):
    faculty = db.query(Faculty).all()

    return faculty


@router.post("/", response_model=FacultyResponse)
def create_faculty(
    faculty: FacultyCreate,
    db: Session = Depends(get_db),
):
    new_faculty = Faculty(
        user_id=faculty.user_id,
        employee_id=faculty.employee_id,
        name=faculty.name,
        email=faculty.email,
        phone=faculty.phone,
        department_id=faculty.department_id,
        designation=faculty.designation,
    )

    db.add(new_faculty)
    db.commit()
    db.refresh(new_faculty)

    return new_faculty


@router.put("/{faculty_id}", response_model=FacultyResponse)
def update_faculty(
    faculty_id: int,
    faculty: FacultyCreate,
    db: Session = Depends(get_db),
):
    existing_faculty = db.query(Faculty).filter(
        Faculty.faculty_id == faculty_id
    ).first()

    if existing_faculty is None:
        raise HTTPException(
            status_code=404,
            detail="Faculty not found",
        )

    existing_faculty.user_id = faculty.user_id
    existing_faculty.employee_id = faculty.employee_id
    existing_faculty.name = faculty.name
    existing_faculty.email = faculty.email
    existing_faculty.phone = faculty.phone
    existing_faculty.department_id = faculty.department_id
    existing_faculty.designation = faculty.designation

    db.commit()
    db.refresh(existing_faculty)

    return existing_faculty


@router.delete("/{faculty_id}")
def delete_faculty(
    faculty_id: int,
    db: Session = Depends(get_db),
):
    existing_faculty = db.query(Faculty).filter(
        Faculty.faculty_id == faculty_id
    ).first()

    if existing_faculty is None:
        raise HTTPException(
            status_code=404,
            detail="Faculty not found",
        )

    db.delete(existing_faculty)
    db.commit()

    return {
        "message": "Faculty deleted successfully",
        "faculty_id": faculty_id,
    }