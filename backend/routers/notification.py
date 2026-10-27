from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Notification
from schemas.notifications import (
    NotificationCreate,
    NotificationResponse,
)


router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)


@router.get("/", response_model=list[NotificationResponse])
def get_notifications(db: Session = Depends(get_db)):
    notifications = db.query(Notification).all()

    return notifications


@router.post("/", response_model=NotificationResponse)
def create_notification(
    notification: NotificationCreate,
    db: Session = Depends(get_db),
):
    new_notification = Notification(
        user_id=notification.user_id,
        title=notification.title,
        message=notification.message,
        notification_type=notification.notification_type,
        is_read=notification.is_read,
    )

    db.add(new_notification)
    db.commit()
    db.refresh(new_notification)

    return new_notification


@router.put(
    "/{notification_id}",
    response_model=NotificationResponse,
)
def update_notification(
    notification_id: int,
    notification: NotificationCreate,
    db: Session = Depends(get_db),
):
    existing_notification = db.query(Notification).filter(
        Notification.notification_id == notification_id
    ).first()

    if existing_notification is None:
        raise HTTPException(
            status_code=404,
            detail="Notification not found",
        )

    existing_notification.user_id = notification.user_id
    existing_notification.title = notification.title
    existing_notification.message = notification.message
    existing_notification.notification_type = (
        notification.notification_type
    )
    existing_notification.is_read = notification.is_read

    db.commit()
    db.refresh(existing_notification)

    return existing_notification


@router.delete("/{notification_id}")
def delete_notification(
    notification_id: int,
    db: Session = Depends(get_db),
):
    existing_notification = db.query(Notification).filter(
        Notification.notification_id == notification_id
    ).first()

    if existing_notification is None:
        raise HTTPException(
            status_code=404,
            detail="Notification not found",
        )

    db.delete(existing_notification)
    db.commit()

    return {
        "message": "Notification deleted successfully",
        "notification_id": notification_id,
    }