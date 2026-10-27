from pydantic import BaseModel, ConfigDict
from datetime import date


class AssignmentBase(BaseModel):
    faculty_id: int
    subject_id: int
    class_id: int
    title: str
    description: str | None = None
    due_date: date


class AssignmentCreate(AssignmentBase):
    pass


class AssignmentResponse(AssignmentBase):
    assignment_id: int

    model_config = ConfigDict(from_attributes=True)