import os
import uuid
from pathlib import Path
from datetime import datetime

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    UploadFile,
    File,
    Form,
)
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from database import get_db
from models import Submission
from schemas.submissions import SubmissionCreate, SubmissionResponse


router = APIRouter(
    prefix="/submissions",
    tags=["Submissions"],
)

# Project root madhye uploads/submissions folder
BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads" / "submissions"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

ALLOWED_EXTENSIONS = {
    ".pdf", ".doc", ".docx",
    ".ppt", ".pptx",
    ".xls", ".xlsx",
    ".zip", ".txt",
}

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


@router.get("/", response_model=list[SubmissionResponse])
def get_submissions(db: Session = Depends(get_db)):
    return db.query(Submission).all()


@router.post("/", response_model=SubmissionResponse)
def create_submission(
    submission: SubmissionCreate,
    db: Session = Depends(get_db),
):
    new_submission = Submission(
        assignment_id=submission.assignment_id,
        student_id=submission.student_id,
        file_url=submission.file_url,
        submission_date=submission.submission_date,
        status=submission.status,
        marks=submission.marks,
        feedback=submission.feedback,
    )

    db.add(new_submission)
    db.commit()
    db.refresh(new_submission)
    return new_submission


@router.post("/upload", response_model=SubmissionResponse)
async def upload_submission(
    assignment_id: int = Form(...),
    student_id: int = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    extension = Path(file.filename or "").suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Unsupported file type.",
        )

    # Upload purn honyapurvi file size limit check kara.
    content = await file.read(MAX_FILE_SIZE + 1)

    if not content:
        raise HTTPException(
            status_code=400,
            detail="The uploaded file is empty.",
        )

    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail="Maximum file size is 10 MB.",
        )

    # Same filename asla tari collision honar nahi.
    stored_name = f"{uuid.uuid4().hex}{extension}"
    destination = UPLOAD_DIR / stored_name

    try:
        # Assignment/student IDs valid aahet ka te check kara.
        from models import Assignment, Student

        assignment = db.query(Assignment).filter(
            Assignment.assignment_id == assignment_id
        ).first()

        student = db.query(Student).filter(
            Student.student_id == student_id
        ).first()

        if assignment is None or student is None:
            raise HTTPException(
                status_code=404,
                detail="Assignment or student not found.",
            )

        # Ekach student chi ekach assignment submission allow kara.
        existing = db.query(Submission).filter(
            Submission.assignment_id == assignment_id,
            Submission.student_id == student_id,
        ).first()

        if existing is not None:
            raise HTTPException(
                status_code=409,
                detail="This assignment has already been submitted.",
            )

        destination.write_bytes(content)

        submission = Submission(
            assignment_id=assignment_id,
            student_id=student_id,
            file_url=f"uploads/submissions/{stored_name}",
            submission_date=datetime.now(),
            status="Submitted",
            marks=None,
            feedback=None,
        )

        db.add(submission)
        db.commit()
        db.refresh(submission)

        return submission

    except Exception:
        db.rollback()

        if destination.exists():
            destination.unlink()

        raise

    finally:
        await file.close()


@router.get("/{submission_id}/file")
def download_submission_file(
    submission_id: int,
    db: Session = Depends(get_db),
):
    submission = db.query(Submission).filter(
        Submission.submission_id == submission_id
    ).first()

    if submission is None or not submission.file_url:
        raise HTTPException(
            status_code=404,
            detail="Submission file not found.",
        )

    # Legacy records madhye fakt filename asu shakto.
    relative_path = Path(submission.file_url)

    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise HTTPException(
            status_code=400,
            detail="Invalid stored file path.",
        )

    # Fakat submissions upload folder madhil files access karta yetil.
    filename = relative_path.name
    file_path = (UPLOAD_DIR / filename).resolve()

    if file_path.parent != UPLOAD_DIR.resolve() or not file_path.is_file():
        raise HTTPException(
            status_code=404,
            detail="File is missing from server storage.",
        )

    return FileResponse(
        path=str(file_path),
        filename=filename,
        media_type="application/octet-stream",
    )


@router.put("/{submission_id}", response_model=SubmissionResponse)
def update_submission(
    submission_id: int,
    submission: SubmissionCreate,
    db: Session = Depends(get_db),
):
    existing = db.query(Submission).filter(
        Submission.submission_id == submission_id
    ).first()

    if existing is None:
        raise HTTPException(
            status_code=404,
            detail="Submission not found",
        )

    existing.assignment_id = submission.assignment_id
    existing.student_id = submission.student_id

    # Review kartana file path chukine overwrite hou naye.
    if submission.file_url:
        existing.file_url = submission.file_url

    existing.submission_date = submission.submission_date
    existing.status = submission.status
    existing.marks = submission.marks
    existing.feedback = submission.feedback

    db.commit()
    db.refresh(existing)
    return existing


@router.delete("/{submission_id}")
def delete_submission(
    submission_id: int,
    db: Session = Depends(get_db),
):
    existing = db.query(Submission).filter(
        Submission.submission_id == submission_id
    ).first()

    if existing is None:
        raise HTTPException(
            status_code=404,
            detail="Submission not found",
        )

    db.delete(existing)
    db.commit()

    return {
        "message": "Submission deleted successfully",
        "submission_id": submission_id,
    }