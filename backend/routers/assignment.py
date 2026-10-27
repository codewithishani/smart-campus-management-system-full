from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Assignment
from schemas.assignments import AssignmentCreate, AssignmentResponse


router = APIRouter(
    prefix="/assignments",
    tags=["Assignments"],
)


@router.get("/", response_model=list[AssignmentResponse])
def get_assignments(db: Session = Depends(get_db)):
    assignments = db.query(Assignment).all()

    return assignments


@router.post("/", response_model=AssignmentResponse)
def create_assignment(
    assignment: AssignmentCreate,
    db: Session = Depends(get_db),
):
    new_assignment = Assignment(
        faculty_id=assignment.faculty_id,
        subject_id=assignment.subject_id,
        class_id=assignment.class_id,
        title=assignment.title,
        description=assignment.description,
        due_date=assignment.due_date,
    )

    db.add(new_assignment)
    db.commit()
    db.refresh(new_assignment)

    return new_assignment


@router.put(
    "/{assignment_id}",
    response_model=AssignmentResponse,
)
def update_assignment(
    assignment_id: int,
    assignment: AssignmentCreate,
    db: Session = Depends(get_db),
):
    existing_assignment = db.query(Assignment).filter(
        Assignment.assignment_id == assignment_id
    ).first()

    if existing_assignment is None:
        raise HTTPException(
            status_code=404,
            detail="Assignment not found",
        )

    existing_assignment.faculty_id = assignment.faculty_id
    existing_assignment.subject_id = assignment.subject_id
    existing_assignment.class_id = assignment.class_id
    existing_assignment.title = assignment.title
    existing_assignment.description = assignment.description
    existing_assignment.due_date = assignment.due_date

    db.commit()
    db.refresh(existing_assignment)

    return existing_assignment


@router.delete("/{assignment_id}")
def delete_assignment(
    assignment_id: int,
    db: Session = Depends(get_db),
):
    existing_assignment = db.query(Assignment).filter(
        Assignment.assignment_id == assignment_id
    ).first()

    if existing_assignment is None:
        raise HTTPException(
            status_code=404,
            detail="Assignment not found",
        )

    db.delete(existing_assignment)
    db.commit()

    return {
        "message": "Assignment deleted successfully",
        "assignment_id": assignment_id,
    }