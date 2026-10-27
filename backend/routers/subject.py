from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Subject
from schemas.subject import SubjectCreate, SubjectResponse


router = APIRouter(
    prefix="/subjects",
    tags=["Subjects"],
)


@router.get("/", response_model=list[SubjectResponse])
def get_subjects(db: Session = Depends(get_db)):
    subjects = db.query(Subject).all()

    return subjects


@router.post("/", response_model=SubjectResponse)
def create_subject(
    subject: SubjectCreate,
    db: Session = Depends(get_db),
):
    new_subject = Subject(
        course_id=subject.course_id,
        subject_name=subject.subject_name,
        subject_code=subject.subject_code,
        semester=subject.semester,
        credits=subject.credits,
        description=subject.description,
    )

    db.add(new_subject)
    db.commit()
    db.refresh(new_subject)

    return new_subject


@router.put("/{subject_id}", response_model=SubjectResponse)
def update_subject(
    subject_id: int,
    subject: SubjectCreate,
    db: Session = Depends(get_db),
):
    existing_subject = db.query(Subject).filter(
        Subject.subject_id == subject_id
    ).first()

    if existing_subject is None:
        raise HTTPException(
            status_code=404,
            detail="Subject not found",
        )

    existing_subject.course_id = subject.course_id
    existing_subject.subject_name = subject.subject_name
    existing_subject.subject_code = subject.subject_code
    existing_subject.semester = subject.semester
    existing_subject.credits = subject.credits
    existing_subject.description = subject.description

    db.commit()
    db.refresh(existing_subject)

    return existing_subject


@router.delete("/{subject_id}")
def delete_subject(
    subject_id: int,
    db: Session = Depends(get_db),
):
    existing_subject = db.query(Subject).filter(
        Subject.subject_id == subject_id
    ).first()

    if existing_subject is None:
        raise HTTPException(
            status_code=404,
            detail="Subject not found",
        )

    db.delete(existing_subject)
    db.commit()

    return {
        "message": "Subject deleted successfully",
        "subject_id": subject_id,
    }