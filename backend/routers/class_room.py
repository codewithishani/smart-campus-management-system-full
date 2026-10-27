from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import ClassRoom
from schemas.class_room import ClassRoomCreate, ClassRoomResponse


router = APIRouter(
    prefix="/classes",
    tags=["Classes"],
)


@router.get("/", response_model=list[ClassRoomResponse])
def get_classes(db: Session = Depends(get_db)):
    classes = db.query(ClassRoom).all()

    return classes


@router.post("/", response_model=ClassRoomResponse)
def create_class(
    class_room: ClassRoomCreate,
    db: Session = Depends(get_db),
):
    new_class = ClassRoom(
        course_id=class_room.course_id,
        class_name=class_room.class_name,
        semester=class_room.semester,
        academic_year=class_room.academic_year,
        class_teacher_id=class_room.class_teacher_id,
    )

    db.add(new_class)
    db.commit()
    db.refresh(new_class)

    return new_class


@router.put("/{class_id}", response_model=ClassRoomResponse)
def update_class(
    class_id: int,
    class_room: ClassRoomCreate,
    db: Session = Depends(get_db),
):
    existing_class = db.query(ClassRoom).filter(
        ClassRoom.class_id == class_id
    ).first()

    if existing_class is None:
        raise HTTPException(
            status_code=404,
            detail="Class not found",
        )

    existing_class.course_id = class_room.course_id
    existing_class.class_name = class_room.class_name
    existing_class.semester = class_room.semester
    existing_class.academic_year = class_room.academic_year
    existing_class.class_teacher_id = class_room.class_teacher_id

    db.commit()
    db.refresh(existing_class)

    return existing_class


@router.delete("/{class_id}")
def delete_class(
    class_id: int,
    db: Session = Depends(get_db),
):
    existing_class = db.query(ClassRoom).filter(
        ClassRoom.class_id == class_id
    ).first()

    if existing_class is None:
        raise HTTPException(
            status_code=404,
            detail="Class not found",
        )

    db.delete(existing_class)
    db.commit()

    return {
        "message": "Class deleted successfully",
        "class_id": class_id,
    }