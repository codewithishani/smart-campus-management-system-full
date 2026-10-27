from pydantic import BaseModel, ConfigDict
from datetime import date, time, datetime


class EventBase(BaseModel):
    created_by: int
    title: str
    description: str
    event_type: str | None = None
    event_date: date
    start_time: time
    end_time: time
    venue: str | None = None
    target_role: str | None = None
    status: str | None = None


class EventCreate(EventBase):
    pass


class EventResponse(EventBase):
    event_id: int
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)