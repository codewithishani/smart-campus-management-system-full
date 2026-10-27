from pydantic import BaseModel, ConfigDict
from datetime import datetime


class NotificationBase(BaseModel):
    user_id: int
    title: str
    message: str
    notification_type: str | None = None
    is_read: bool = False


class NotificationCreate(NotificationBase):
    pass


class NotificationResponse(NotificationBase):
    notification_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)