from pydantic import BaseModel, ConfigDict
from datetime import datetime


class ResultBase(BaseModel):
    exam_id: int
    student_id: int
    subject_id: int
    marks_obtained: float
    total_marks: float
    grade: str | None = None
    result_status: str | None = None
    remarks: str | None = None


class ResultCreate(ResultBase):
    pass


class ResultResponse(ResultBase):
    result_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)