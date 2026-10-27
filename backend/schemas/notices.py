from pydantic import BaseModel, ConfigDict
from datetime import date, datetime


class NoticeBase(BaseModel):
    user_id: int
    title: str
    description: str
    notice_type: str | None = None
    target_role: str | None = None
    publish_date: date
    expiry_date: date | None = None
    status: str | None = None


class NoticeCreate(NoticeBase):
    pass


class NoticeResponse(NoticeBase):
    notice_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)