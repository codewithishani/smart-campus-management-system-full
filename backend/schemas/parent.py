from pydantic import BaseModel, ConfigDict


class ParentBase(BaseModel):
    user_id: int
    name: str
    email: str
    phone: str | None = None
    address: str | None = None


class ParentCreate(ParentBase):
    pass


class ParentResponse(ParentBase):
    parent_id: int

    model_config = ConfigDict(from_attributes=True)