from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Parent
from schemas.parent import ParentCreate, ParentResponse


router = APIRouter(
    prefix="/parents",
    tags=["Parents"],
)


@router.get("/", response_model=list[ParentResponse])
def get_parents(db: Session = Depends(get_db)):
    parents = db.query(Parent).all()

    return parents


@router.post("/", response_model=ParentResponse)
def create_parent(
    parent: ParentCreate,
    db: Session = Depends(get_db),
):
    new_parent = Parent(
        user_id=parent.user_id,
        name=parent.name,
        email=parent.email,
        phone=parent.phone,
        address=parent.address,
    )

    db.add(new_parent)
    db.commit()
    db.refresh(new_parent)

    return new_parent


@router.put("/{parent_id}", response_model=ParentResponse)
def update_parent(
    parent_id: int,
    parent: ParentCreate,
    db: Session = Depends(get_db),
):
    existing_parent = db.query(Parent).filter(
        Parent.parent_id == parent_id
    ).first()

    if existing_parent is None:
        raise HTTPException(
            status_code=404,
            detail="Parent not found",
        )

    existing_parent.user_id = parent.user_id
    existing_parent.name = parent.name
    existing_parent.email = parent.email
    existing_parent.phone = parent.phone
    existing_parent.address = parent.address

    db.commit()
    db.refresh(existing_parent)

    return existing_parent


@router.delete("/{parent_id}")
def delete_parent(
    parent_id: int,
    db: Session = Depends(get_db),
):
    existing_parent = db.query(Parent).filter(
        Parent.parent_id == parent_id
    ).first()

    if existing_parent is None:
        raise HTTPException(
            status_code=404,
            detail="Parent not found",
        )

    db.delete(existing_parent)
    db.commit()

    return {
        "message": "Parent deleted successfully",
        "parent_id": parent_id,
    }