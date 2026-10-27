from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Timetable
from schemas.timetable import TimetableCreate, TimetableResponse


router = APIRouter(
    prefix="/timetable",
    tags=["Timetable"],
)


@router.get("/", response_model=list[TimetableResponse])
def get_timetable(db: Session = Depends(get_db)):
    timetable = db.query(Timetable).all()

    return timetable


@router.post("/", response_model=TimetableResponse)
def create_timetable(
    timetable: TimetableCreate,
    db: Session = Depends(get_db),
):
    new_timetable = Timetable(
        class_id=timetable.class_id,
        subject_id=timetable.subject_id,
        faculty_id=timetable.faculty_id,
        day=timetable.day,
        start_time=timetable.start_time,
        end_time=timetable.end_time,
        room_no=timetable.room_no,
    )

    db.add(new_timetable)
    db.commit()
    db.refresh(new_timetable)

    return new_timetable


@router.put(
    "/{timetable_id}",
    response_model=TimetableResponse,
)
def update_timetable(
    timetable_id: int,
    timetable: TimetableCreate,
    db: Session = Depends(get_db),
):
    existing_timetable = db.query(Timetable).filter(
        Timetable.timetable_id == timetable_id
    ).first()

    if existing_timetable is None:
        raise HTTPException(
            status_code=404,
            detail="Timetable entry not found",
        )

    existing_timetable.class_id = timetable.class_id
    existing_timetable.subject_id = timetable.subject_id
    existing_timetable.faculty_id = timetable.faculty_id
    existing_timetable.day = timetable.day
    existing_timetable.start_time = timetable.start_time
    existing_timetable.end_time = timetable.end_time
    existing_timetable.room_no = timetable.room_no

    db.commit()
    db.refresh(existing_timetable)

    return existing_timetable


@router.delete("/{timetable_id}")
def delete_timetable(
    timetable_id: int,
    db: Session = Depends(get_db),
):
    existing_timetable = db.query(Timetable).filter(
        Timetable.timetable_id == timetable_id
    ).first()

    if existing_timetable is None:
        raise HTTPException(
            status_code=404,
            detail="Timetable entry not found",
        )

    db.delete(existing_timetable)
    db.commit()

    return {
        "message": "Timetable entry deleted successfully",
        "timetable_id": timetable_id,
    }