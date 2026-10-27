from pydantic import BaseModel, ConfigDict
from datetime import date, datetime


class ComplaintBase(BaseModel):
    student_id: int
    assigned_to: int | None = None
    title: str
    description: str
    complaint_type: str | None = None
    priority: str | None = None
    status: str | None = None
    submitted_at: datetime | None = None
    resolved_at: datetime | None = None


class ComplaintCreate(ComplaintBase):
    pass


class ComplaintResponse(ComplaintBase):
    complaint_id: int

    model_config = ConfigDict(from_attributes=True)