from pydantic import BaseModel, ConfigDict
from datetime import datetime


class SubmissionBase(BaseModel):
    assignment_id: int
    student_id: int
    file_url: str | None = None
    submission_date: datetime
    status: str | None = None
    marks: float | None = None
    feedback: str | None = None


class SubmissionCreate(SubmissionBase):
    pass


class SubmissionResponse(SubmissionBase):
    submission_id: int

    model_config = ConfigDict(from_attributes=True)