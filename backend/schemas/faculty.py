from pydantic import BaseModel, ConfigDict


class FacultyBase(BaseModel):
    user_id: int
    employee_id: str
    name: str
    email: str
    phone: str | None = None
    department_id: int
    designation: str | None = None


class FacultyCreate(FacultyBase):
    pass


class FacultyResponse(FacultyBase):
    faculty_id: int

    model_config = ConfigDict(
        from_attributes=True
    )