from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Department
from schemas.department import DepartmentCreate, DepartmentResponse


router = APIRouter(
    prefix="/departments",
    tags=["Departments"],
)


@router.get("/", response_model=list[DepartmentResponse])
def get_departments(db: Session = Depends(get_db)):
    departments = db.query(Department).all()

    return departments


@router.post("/", response_model=DepartmentResponse)
def create_department(
    department: DepartmentCreate,
    db: Session = Depends(get_db),
):
    new_department = Department(
        department_name=department.department_name,
        description=department.description,
        hod_name=department.hod_name,
    )

    db.add(new_department)
    db.commit()
    db.refresh(new_department)

    return new_department


@router.put("/{department_id}", response_model=DepartmentResponse)
def update_department(
    department_id: int,
    department: DepartmentCreate,
    db: Session = Depends(get_db),
):
    existing_department = db.query(Department).filter(
        Department.department_id == department_id
    ).first()

    if existing_department is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    existing_department.department_name = department.department_name
    existing_department.description = department.description
    existing_department.hod_name = department.hod_name

    db.commit()
    db.refresh(existing_department)

    return existing_department


@router.delete("/{department_id}")
def delete_department(
    department_id: int,
    db: Session = Depends(get_db),
):
    existing_department = db.query(Department).filter(
        Department.department_id == department_id
    ).first()

    if existing_department is None:
        raise HTTPException(
            status_code=404,
            detail="Department not found",
        )

    db.delete(existing_department)
    db.commit()

    return {
        "message": "Department deleted successfully",
        "department_id": department_id,
    }