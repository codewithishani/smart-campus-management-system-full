from datetime import date
from pydantic import BaseModel, ConfigDict


class AttendanceBase(BaseModel):
    student_id: int
    subject_id: int
    faculty_id: int
    attendance_date: date
    status: str
    remarks: str | None = None


class AttendanceCreate(AttendanceBase):
    pass


class AttendanceResponse(AttendanceBase):
    attendance_id: int

    model_config = ConfigDict(from_attributes=True)