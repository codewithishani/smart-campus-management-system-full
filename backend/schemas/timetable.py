from datetime import time
from pydantic import BaseModel, ConfigDict


class TimetableBase(BaseModel):
    class_id: int
    subject_id: int
    faculty_id: int
    day: str
    start_time: time
    end_time: time
    room_no: str | None = None

class TimetableCreate(TimetableBase):
    pass


class TimetableResponse(TimetableBase):
    timetable_id: int

    model_config = ConfigDict(from_attributes=True)