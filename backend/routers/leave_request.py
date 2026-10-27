from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import LeaveRequest
from schemas.leave_requests import (
    LeaveRequestCreate,
    LeaveRequestResponse,
)


router = APIRouter(
    prefix="/leave-requests",
    tags=["Leave Requests"],
)


@router.get(
    "/",
    response_model=list[LeaveRequestResponse],
)
def get_leave_requests(db: Session = Depends(get_db)):
    leave_requests = db.query(LeaveRequest).all()

    return leave_requests


@router.post(
    "/",
    response_model=LeaveRequestResponse,
)
def create_leave_request(
    leave_request: LeaveRequestCreate,
    db: Session = Depends(get_db),
):
    new_leave_request = LeaveRequest(
        user_id=leave_request.user_id,
        from_date=leave_request.from_date,
        to_date=leave_request.to_date,
        reason=leave_request.reason,
        leave_type=leave_request.leave_type,
        status=leave_request.status,
        approved_by=leave_request.approved_by,
        remarks=leave_request.remarks,
    )

    db.add(new_leave_request)
    db.commit()
    db.refresh(new_leave_request)

    return new_leave_request


@router.put(
    "/{leave_id}",
    response_model=LeaveRequestResponse,
)
def update_leave_request(
    leave_id: int,
    leave_request: LeaveRequestCreate,
    db: Session = Depends(get_db),
):
    existing_leave_request = db.query(LeaveRequest).filter(
        LeaveRequest.leave_id == leave_id
    ).first()

    if existing_leave_request is None:
        raise HTTPException(
            status_code=404,
            detail="Leave request not found",
        )

    existing_leave_request.user_id = leave_request.user_id
    existing_leave_request.from_date = leave_request.from_date
    existing_leave_request.to_date = leave_request.to_date
    existing_leave_request.reason = leave_request.reason
    existing_leave_request.leave_type = leave_request.leave_type
    existing_leave_request.status = leave_request.status
    existing_leave_request.approved_by = leave_request.approved_by
    existing_leave_request.remarks = leave_request.remarks

    db.commit()
    db.refresh(existing_leave_request)

    return existing_leave_request


@router.delete("/{leave_id}")
def delete_leave_request(
    leave_id: int,
    db: Session = Depends(get_db),
):
    existing_leave_request = db.query(LeaveRequest).filter(
        LeaveRequest.leave_id == leave_id
    ).first()

    if existing_leave_request is None:
        raise HTTPException(
            status_code=404,
            detail="Leave request not found",
        )

    db.delete(existing_leave_request)
    db.commit()

    return {
        "message": "Leave request deleted successfully",
        "leave_id": leave_id,
    }