from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Notice
from schemas.notices import NoticeCreate, NoticeResponse


router = APIRouter(
    prefix="/notices",
    tags=["Notices"],
)


@router.get("/", response_model=list[NoticeResponse])
def get_notices(db: Session = Depends(get_db)):
    notices = db.query(Notice).all()

    return notices


@router.post("/", response_model=NoticeResponse)
def create_notice(
    notice: NoticeCreate,
    db: Session = Depends(get_db),
):
    new_notice = Notice(
        user_id=notice.user_id,
        title=notice.title,
        description=notice.description,
        notice_type=notice.notice_type,
        target_role=notice.target_role,
        publish_date=notice.publish_date,
        expiry_date=notice.expiry_date,
        status=notice.status,
    )

    db.add(new_notice)
    db.commit()
    db.refresh(new_notice)

    return new_notice


@router.put(
    "/{notice_id}",
    response_model=NoticeResponse,
)
def update_notice(
    notice_id: int,
    notice: NoticeCreate,
    db: Session = Depends(get_db),
):
    existing_notice = db.query(Notice).filter(
        Notice.notice_id == notice_id
    ).first()

    if existing_notice is None:
        raise HTTPException(
            status_code=404,
            detail="Notice not found",
        )

    existing_notice.user_id = notice.user_id
    existing_notice.title = notice.title
    existing_notice.description = notice.description
    existing_notice.notice_type = notice.notice_type
    existing_notice.target_role = notice.target_role
    existing_notice.publish_date = notice.publish_date
    existing_notice.expiry_date = notice.expiry_date
    existing_notice.status = notice.status

    db.commit()
    db.refresh(existing_notice)

    return existing_notice


@router.delete("/{notice_id}")
def delete_notice(
    notice_id: int,
    db: Session = Depends(get_db),
):
    existing_notice = db.query(Notice).filter(
        Notice.notice_id == notice_id
    ).first()

    if existing_notice is None:
        raise HTTPException(
            status_code=404,
            detail="Notice not found",
        )

    db.delete(existing_notice)
    db.commit()

    return {
        "message": "Notice deleted successfully",
        "notice_id": notice_id,
    }