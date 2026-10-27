from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Result
from schemas.results import ResultCreate, ResultResponse


router = APIRouter(
    prefix="/results",
    tags=["Results"],
)


@router.get("/", response_model=list[ResultResponse])
def get_results(db: Session = Depends(get_db)):
    results = db.query(Result).all()

    return results


@router.post("/", response_model=ResultResponse)
def create_result(
    result: ResultCreate,
    db: Session = Depends(get_db),
):
    new_result = Result(
        exam_id=result.exam_id,
        student_id=result.student_id,
        subject_id=result.subject_id,
        marks_obtained=result.marks_obtained,
        total_marks=result.total_marks,
        grade=result.grade,
        result_status=result.result_status,
        remarks=result.remarks,
    )

    db.add(new_result)
    db.commit()
    db.refresh(new_result)

    return new_result


@router.put(
    "/{result_id}",
    response_model=ResultResponse,
)
def update_result(
    result_id: int,
    result: ResultCreate,
    db: Session = Depends(get_db),
):
    existing_result = db.query(Result).filter(
        Result.result_id == result_id
    ).first()

    if existing_result is None:
        raise HTTPException(
            status_code=404,
            detail="Result not found",
        )

    existing_result.exam_id = result.exam_id
    existing_result.student_id = result.student_id
    existing_result.subject_id = result.subject_id
    existing_result.marks_obtained = result.marks_obtained
    existing_result.total_marks = result.total_marks
    existing_result.grade = result.grade
    existing_result.result_status = result.result_status
    existing_result.remarks = result.remarks

    db.commit()
    db.refresh(existing_result)

    return existing_result


@router.delete("/{result_id}")
def delete_result(
    result_id: int,
    db: Session = Depends(get_db),
):
    existing_result = db.query(Result).filter(
        Result.result_id == result_id
    ).first()

    if existing_result is None:
        raise HTTPException(
            status_code=404,
            detail="Result not found",
        )

    db.delete(existing_result)
    db.commit()

    return {
        "message": "Result deleted successfully",
        "result_id": result_id,
    }