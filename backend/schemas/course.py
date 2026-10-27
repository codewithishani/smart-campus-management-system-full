from pydantic import BaseModel, ConfigDict


class CourseBase(BaseModel):
    department_id: int
    course_name: str
    course_code: str
    duration: int | None = None
    description: str | None = None


class CourseCreate(CourseBase):
    pass


class CourseResponse(CourseBase):
    course_id: int

    model_config = ConfigDict(from_attributes=True)