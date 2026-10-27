from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Attendance
from schemas.attendance import AttendanceCreate, AttendanceResponse


router = APIRouter(
    prefix="/attendance",
    tags=["Attendance"],
)


@router.get("/", response_model=list[AttendanceResponse])
def get_attendance(db: Session = Depends(get_db)):
    attendance = db.query(Attendance).all()

    return attendance


@router.post("/", response_model=AttendanceResponse)
def create_attendance(
    attendance: AttendanceCreate,
    db: Session = Depends(get_db),
):
    new_attendance = Attendance(
        student_id=attendance.student_id,
        subject_id=attendance.subject_id,
        faculty_id=attendance.faculty_id,
        attendance_date=attendance.attendance_date,
        status=attendance.status,
        remarks=attendance.remarks,
    )

    db.add(new_attendance)
    db.commit()
    db.refresh(new_attendance)

    return new_attendance


@router.put(
    "/{attendance_id}",
    response_model=AttendanceResponse,
)
def update_attendance(
    attendance_id: int,
    attendance: AttendanceCreate,
    db: Session = Depends(get_db),
):
    existing_attendance = db.query(Attendance).filter(
        Attendance.attendance_id == attendance_id
    ).first()

    if existing_attendance is None:
        raise HTTPException(
            status_code=404,
            detail="Attendance record not found",
        )

    existing_attendance.student_id = attendance.student_id
    existing_attendance.subject_id = attendance.subject_id
    existing_attendance.faculty_id = attendance.faculty_id
    existing_attendance.attendance_date = attendance.attendance_date
    existing_attendance.status = attendance.status
    existing_attendance.remarks = attendance.remarks

    db.commit()
    db.refresh(existing_attendance)

    return existing_attendance


@router.delete("/{attendance_id}")
def delete_attendance(
    attendance_id: int,
    db: Session = Depends(get_db),
):
    existing_attendance = db.query(Attendance).filter(
        Attendance.attendance_id == attendance_id
    ).first()

    if existing_attendance is None:
        raise HTTPException(
            status_code=404,
            detail="Attendance record not found",
        )

    db.delete(existing_attendance)
    db.commit()

    return {
        "message": "Attendance record deleted successfully",
        "attendance_id": attendance_id,
    }