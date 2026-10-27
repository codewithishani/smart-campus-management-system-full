from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Note
from schemas.notes import NoteCreate, NoteResponse


router = APIRouter(
    prefix="/notes",
    tags=["Notes"],
)


@router.get("/", response_model=list[NoteResponse])
def get_notes(db: Session = Depends(get_db)):
    notes = db.query(Note).all()

    return notes


@router.post("/", response_model=NoteResponse)
def create_note(
    note: NoteCreate,
    db: Session = Depends(get_db),
):
    new_note = Note(
        faculty_id=note.faculty_id,
        subject_id=note.subject_id,
        class_id=note.class_id,
        title=note.title,
        description=note.description,
        file_url=note.file_url,
    )

    db.add(new_note)
    db.commit()
    db.refresh(new_note)

    return new_note


@router.put(
    "/{note_id}",
    response_model=NoteResponse,
)
def update_note(
    note_id: int,
    note: NoteCreate,
    db: Session = Depends(get_db),
):
    existing_note = db.query(Note).filter(
        Note.note_id == note_id
    ).first()

    if existing_note is None:
        raise HTTPException(
            status_code=404,
            detail="Note not found",
        )

    existing_note.faculty_id = note.faculty_id
    existing_note.subject_id = note.subject_id
    existing_note.class_id = note.class_id
    existing_note.title = note.title
    existing_note.description = note.description
    existing_note.file_url = note.file_url

    db.commit()
    db.refresh(existing_note)

    return existing_note


@router.delete("/{note_id}")
def delete_note(
    note_id: int,
    db: Session = Depends(get_db),
):
    existing_note = db.query(Note).filter(
        Note.note_id == note_id
    ).first()

    if existing_note is None:
        raise HTTPException(
            status_code=404,
            detail="Note not found",
        )

    db.delete(existing_note)
    db.commit()

    return {
        "message": "Note deleted successfully",
        "note_id": note_id,
    }