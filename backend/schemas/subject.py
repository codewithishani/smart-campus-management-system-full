from pydantic import BaseModel, ConfigDict


class SubjectBase(BaseModel):
    course_id: int
    subject_name: str
    subject_code: str
    semester: int | None = None
    credits: int | None = None
    description: str | None = None


class SubjectCreate(SubjectBase):
    pass


class SubjectResponse(SubjectBase):
    subject_id: int

    model_config = ConfigDict(from_attributes=True)