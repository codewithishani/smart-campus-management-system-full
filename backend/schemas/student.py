from pydantic import BaseModel, ConfigDict


class StudentBase(BaseModel):
    user_id: int
    roll_no: str
    name: str
    email: str
    phone: str | None = None
    department_id: int
    course_id: int
    semester: int | None = None
    address: str | None = None


class StudentCreate(StudentBase):
    pass


class StudentResponse(StudentBase):
    student_id: int

    model_config = ConfigDict(from_attributes=True)