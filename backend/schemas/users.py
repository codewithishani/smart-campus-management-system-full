from pydantic import BaseModel, ConfigDict
from datetime import datetime


class RoleBase(BaseModel):
    role_name: str
    description: str | None = None


class RoleCreate(RoleBase):
    pass


class RoleResponse(RoleBase):
    role_id: int

    model_config = ConfigDict(from_attributes=True)


class UserBase(BaseModel):
    name: str
    email: str
    phone: str | None = None
    role_id: int
    is_active: bool = True


class UserCreate(UserBase):
    password: str


class UserResponse(UserBase):
    user_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)