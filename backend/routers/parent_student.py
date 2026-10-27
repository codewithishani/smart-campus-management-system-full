from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import ParentStudent
from schemas.parent_student import (
    ParentStudentCreate,
    ParentStudentResponse,
)


router = APIRouter(
    prefix="/parent-student",
    tags=["Parent-Student"],
)


@router.get(
    "/",
    response_model=list[ParentStudentResponse],
)
def get_parent_student_links(db: Session = Depends(get_db)):
    links = db.query(ParentStudent).all()

    return links


@router.post(
    "/",
    response_model=ParentStudentResponse,
)
def create_parent_student_link(
    link: ParentStudentCreate,
    db: Session = Depends(get_db),
):
    new_link = ParentStudent(
        parent_id=link.parent_id,
        student_id=link.student_id,
        relationship_type=link.relationship_type,
        is_primary=link.is_primary,
    )

    db.add(new_link)
    db.commit()
    db.refresh(new_link)

    return new_link


@router.put(
    "/{parent_student_id}",
    response_model=ParentStudentResponse,
)
def update_parent_student_link(
    parent_student_id: int,
    link: ParentStudentCreate,
    db: Session = Depends(get_db),
):
    existing_link = db.query(ParentStudent).filter(
        ParentStudent.parent_student_id == parent_student_id
    ).first()

    if existing_link is None:
        raise HTTPException(
            status_code=404,
            detail="Parent-student link not found",
        )

    existing_link.parent_id = link.parent_id
    existing_link.student_id = link.student_id
    existing_link.relationship_type = link.relationship_type
    existing_link.is_primary = link.is_primary

    db.commit()
    db.refresh(existing_link)

    return existing_link


@router.delete("/{parent_student_id}")
def delete_parent_student_link(
    parent_student_id: int,
    db: Session = Depends(get_db),
):
    existing_link = db.query(ParentStudent).filter(
        ParentStudent.parent_student_id == parent_student_id
    ).first()

    if existing_link is None:
        raise HTTPException(
            status_code=404,
            detail="Parent-student link not found",
        )

    db.delete(existing_link)
    db.commit()

    return {
        "message": "Parent-student link deleted successfully",
        "parent_student_id": parent_student_id,
    }