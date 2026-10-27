from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Exam
from schemas.exams import ExamCreate, ExamResponse


router = APIRouter(
    prefix="/exams",
    tags=["Exams"],
)


@router.get("/", response_model=list[ExamResponse])
def get_exams(db: Session = Depends(get_db)):
    exams = db.query(Exam).all()

    return exams


@router.post("/", response_model=ExamResponse)
def create_exam(
    exam: ExamCreate,
    db: Session = Depends(get_db),
):
    new_exam = Exam(
        course_id=exam.course_id,
        subject_id=exam.subject_id,
        class_id=exam.class_id,
        exam_name=exam.exam_name,
        exam_date=exam.exam_date,
        start_time=exam.start_time,
        end_time=exam.end_time,
        room_no=exam.room_no,
    )

    db.add(new_exam)
    db.commit()
    db.refresh(new_exam)

    return new_exam


@router.put(
    "/{exam_id}",
    response_model=ExamResponse,
)
def update_exam(
    exam_id: int,
    exam: ExamCreate,
    db: Session = Depends(get_db),
):
    existing_exam = db.query(Exam).filter(
        Exam.exam_id == exam_id
    ).first()

    if existing_exam is None:
        raise HTTPException(
            status_code=404,
            detail="Exam not found",
        )

    existing_exam.course_id = exam.course_id
    existing_exam.subject_id = exam.subject_id
    existing_exam.class_id = exam.class_id
    existing_exam.exam_name = exam.exam_name
    existing_exam.exam_date = exam.exam_date
    existing_exam.start_time = exam.start_time
    existing_exam.end_time = exam.end_time
    existing_exam.room_no = exam.room_no

    db.commit()
    db.refresh(existing_exam)

    return existing_exam


@router.delete("/{exam_id}")
def delete_exam(
    exam_id: int,
    db: Session = Depends(get_db),
):
    existing_exam = db.query(Exam).filter(
        Exam.exam_id == exam_id
    ).first()

    if existing_exam is None:
        raise HTTPException(
            status_code=404,
            detail="Exam not found",
        )

    db.delete(existing_exam)
    db.commit()

    return {
        "message": "Exam deleted successfully",
        "exam_id": exam_id,
    }