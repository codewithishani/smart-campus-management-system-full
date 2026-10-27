from pydantic import BaseModel, ConfigDict


class NoteBase(BaseModel):
    faculty_id: int
    subject_id: int
    class_id: int
    title: str
    description: str | None = None
    file_url: str | None = None


class NoteCreate(NoteBase):
    pass


class NoteResponse(NoteBase):
    note_id: int

    model_config = ConfigDict(from_attributes=True)