from pydantic import BaseModel, ConfigDict


class ClassRoomBase(BaseModel):
    course_id: int
    class_name: str
    semester: int | None = None
    academic_year: str | None = None
    class_teacher_id: int | None = None


class ClassRoomCreate(ClassRoomBase):
    pass


class ClassRoomResponse(ClassRoomBase):
    class_id: int

    model_config = ConfigDict(from_attributes=True)