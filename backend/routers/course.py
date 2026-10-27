from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Course
from schemas.course import CourseCreate, CourseResponse


router = APIRouter(
    prefix="/courses",
    tags=["Courses"],
)


@router.get("/", response_model=list[CourseResponse])
def get_courses(db: Session = Depends(get_db)):
    courses = db.query(Course).all()

    return courses


@router.post("/", response_model=CourseResponse)
def create_course(
    course: CourseCreate,
    db: Session = Depends(get_db),
):
    new_course = Course(
        department_id=course.department_id,
        course_name=course.course_name,
        course_code=course.course_code,
        duration=course.duration,
        description=course.description,
    )

    db.add(new_course)
    db.commit()
    db.refresh(new_course)

    return new_course


@router.put("/{course_id}", response_model=CourseResponse)
def update_course(
    course_id: int,
    course: CourseCreate,
    db: Session = Depends(get_db),
):
    existing_course = db.query(Course).filter(
        Course.course_id == course_id
    ).first()

    if existing_course is None:
        raise HTTPException(
            status_code=404,
            detail="Course not found",
        )

    existing_course.department_id = course.department_id
    existing_course.course_name = course.course_name
    existing_course.course_code = course.course_code
    existing_course.duration = course.duration
    existing_course.description = course.description

    db.commit()
    db.refresh(existing_course)

    return existing_course


@router.delete("/{course_id}")
def delete_course(
    course_id: int,
    db: Session = Depends(get_db),
):
    existing_course = db.query(Course).filter(
        Course.course_id == course_id
    ).first()

    if existing_course is None:
        raise HTTPException(
            status_code=404,
            detail="Course not found",
        )

    db.delete(existing_course)
    db.commit()

    return {
        "message": "Course deleted successfully",
        "course_id": course_id,
    }