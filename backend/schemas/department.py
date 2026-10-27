from pydantic import BaseModel, ConfigDict


class DepartmentBase(BaseModel):
    department_name: str
    description: str | None = None
    hod_name: str | None = None


class DepartmentCreate(DepartmentBase):
    pass


class DepartmentResponse(DepartmentBase):
    department_id: int

    model_config = ConfigDict(from_attributes=True)