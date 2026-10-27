from pydantic import BaseModel, ConfigDict
from datetime import date, time


class ExamBase(BaseModel):
    course_id: int
    subject_id: int
    class_id: int
    exam_name: str
    exam_date: date
    start_time: time
    end_time: time
    room_no: str | None = None


class ExamCreate(ExamBase):
    pass


class ExamResponse(ExamBase):
    exam_id: int

    model_config = ConfigDict(from_attributes=True)