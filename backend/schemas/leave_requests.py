from pydantic import BaseModel, ConfigDict
from datetime import date, datetime


class LeaveRequestBase(BaseModel):
    user_id: int
    from_date: date
    to_date: date
    reason: str
    leave_type: str | None = None
    status: str | None = None
    approved_by: int | None = None
    remarks: str | None = None


class LeaveRequestCreate(LeaveRequestBase):
    pass


class LeaveRequestResponse(LeaveRequestBase):
    leave_id: int
    requested_at: datetime | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)