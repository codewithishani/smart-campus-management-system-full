from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Event
from schemas.events import EventCreate, EventResponse


router = APIRouter(
    prefix="/events",
    tags=["Events"],
)


@router.get("/", response_model=list[EventResponse])
def get_events(db: Session = Depends(get_db)):
    events = db.query(Event).all()

    return events


@router.post("/", response_model=EventResponse)
def create_event(
    event: EventCreate,
    db: Session = Depends(get_db),
):
    new_event = Event(
        created_by=event.created_by,
        title=event.title,
        description=event.description,
        event_type=event.event_type,
        event_date=event.event_date,
        start_time=event.start_time,
        end_time=event.end_time,
        venue=event.venue,
        target_role=event.target_role,
        status=event.status,
    )

    db.add(new_event)
    db.commit()
    db.refresh(new_event)

    return new_event


@router.put(
    "/{event_id}",
    response_model=EventResponse,
)
def update_event(
    event_id: int,
    event: EventCreate,
    db: Session = Depends(get_db),
):
    existing_event = db.query(Event).filter(
        Event.event_id == event_id
    ).first()

    if existing_event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    existing_event.created_by = event.created_by
    existing_event.title = event.title
    existing_event.description = event.description
    existing_event.event_type = event.event_type
    existing_event.event_date = event.event_date
    existing_event.start_time = event.start_time
    existing_event.end_time = event.end_time
    existing_event.venue = event.venue
    existing_event.target_role = event.target_role
    existing_event.status = event.status

    db.commit()
    db.refresh(existing_event)

    return existing_event


@router.delete("/{event_id}")
def delete_event(
    event_id: int,
    db: Session = Depends(get_db),
):
    existing_event = db.query(Event).filter(
        Event.event_id == event_id
    ).first()

    if existing_event is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    db.delete(existing_event)
    db.commit()

    return {
        "message": "Event deleted successfully",
        "event_id": event_id,
    }