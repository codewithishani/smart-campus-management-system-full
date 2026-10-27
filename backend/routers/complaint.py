from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Complaint
from schemas.complaints import ComplaintCreate, ComplaintResponse


router = APIRouter(
    prefix="/complaints",
    tags=["Complaints"],
)


@router.get("/", response_model=list[ComplaintResponse])
def get_complaints(db: Session = Depends(get_db)):
    complaints = db.query(Complaint).all()

    return complaints


@router.post("/", response_model=ComplaintResponse)
def create_complaint(
    complaint: ComplaintCreate,
    db: Session = Depends(get_db),
):
    new_complaint = Complaint(
        student_id=complaint.student_id,
        assigned_to=complaint.assigned_to,
        title=complaint.title,
        description=complaint.description,
        complaint_type=complaint.complaint_type,
        priority=complaint.priority,
        status=complaint.status,
        submitted_at=complaint.submitted_at,
        resolved_at=complaint.resolved_at,
    )

    db.add(new_complaint)
    db.commit()
    db.refresh(new_complaint)

    return new_complaint


@router.put(
    "/{complaint_id}",
    response_model=ComplaintResponse,
)
def update_complaint(
    complaint_id: int,
    complaint: ComplaintCreate,
    db: Session = Depends(get_db),
):
    existing_complaint = db.query(Complaint).filter(
        Complaint.complaint_id == complaint_id
    ).first()

    if existing_complaint is None:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found",
        )

    existing_complaint.student_id = complaint.student_id
    existing_complaint.assigned_to = complaint.assigned_to
    existing_complaint.title = complaint.title
    existing_complaint.description = complaint.description
    existing_complaint.complaint_type = complaint.complaint_type
    existing_complaint.priority = complaint.priority
    existing_complaint.status = complaint.status
    existing_complaint.submitted_at = complaint.submitted_at
    existing_complaint.resolved_at = complaint.resolved_at

    db.commit()
    db.refresh(existing_complaint)

    return existing_complaint


@router.delete("/{complaint_id}")
def delete_complaint(
    complaint_id: int,
    db: Session = Depends(get_db),
):
    existing_complaint = db.query(Complaint).filter(
        Complaint.complaint_id == complaint_id
    ).first()

    if existing_complaint is None:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found",
        )

    db.delete(existing_complaint)
    db.commit()

    return {
        "message": "Complaint deleted successfully",
        "complaint_id": complaint_id,
    }