from pydantic import BaseModel, ConfigDict
from datetime import datetime


class ParentStudentBase(BaseModel):
    parent_id: int
    student_id: int
    relationship_type: str | None = None
    is_primary: bool = False


class ParentStudentCreate(ParentStudentBase):
    pass


class ParentStudentResponse(ParentStudentBase):
    parent_student_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)