from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pwdlib import PasswordHash

from database import get_db
from models import Role, User
from schemas.users import (
    RoleCreate,
    RoleResponse,
    UserCreate,
    UserResponse,
)


password_hash = PasswordHash.recommended()


router = APIRouter(
    prefix="/users",
    tags=["Users & Roles"],
)


# =========================
# USERS
# =========================

@router.get(
    "/",
    response_model=list[UserResponse],
)
def get_users(db: Session = Depends(get_db)):
    users = db.query(User).all()

    return users


@router.post(
    "/",
    response_model=UserResponse,
)
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
):
    new_user = User(
        name=user.name,
        email=user.email,
        password=password_hash.hash(user.password),
        phone=user.phone,
        role_id=user.role_id,
        is_active=user.is_active,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


@router.put(
    "/{user_id}",
    response_model=UserResponse,
)
def update_user(
    user_id: int,
    user: UserCreate,
    db: Session = Depends(get_db),
):
    existing_user = db.query(User).filter(
        User.user_id == user_id
    ).first()

    if existing_user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    existing_user.name = user.name
    existing_user.email = user.email
    existing_user.password = password_hash.hash(
        user.password
    )
    existing_user.phone = user.phone
    existing_user.role_id = user.role_id
    existing_user.is_active = user.is_active

    db.commit()
    db.refresh(existing_user)

    return existing_user


@router.delete("/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
):
    existing_user = db.query(User).filter(
        User.user_id == user_id
    ).first()

    if existing_user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    db.delete(existing_user)
    db.commit()

    return {
        "message": "User deleted successfully",
        "user_id": user_id,
    }


# =========================
# ROLES
# =========================

@router.get(
    "/roles",
    response_model=list[RoleResponse],
)
def get_roles(db: Session = Depends(get_db)):
    roles = db.query(Role).all()

    return roles


@router.post(
    "/roles",
    response_model=RoleResponse,
)
def create_role(
    role: RoleCreate,
    db: Session = Depends(get_db),
):
    new_role = Role(
        role_name=role.role_name,
        description=role.description,
    )

    db.add(new_role)
    db.commit()
    db.refresh(new_role)

    return new_role


@router.put(
    "/roles/{role_id}",
    response_model=RoleResponse,
)
def update_role(
    role_id: int,
    role: RoleCreate,
    db: Session = Depends(get_db),
):
    existing_role = db.query(Role).filter(
        Role.role_id == role_id
    ).first()

    if existing_role is None:
        raise HTTPException(
            status_code=404,
            detail="Role not found",
        )

    existing_role.role_name = role.role_name
    existing_role.description = role.description

    db.commit()
    db.refresh(existing_role)

    return existing_role


@router.delete("/roles/{role_id}")
def delete_role(
    role_id: int,
    db: Session = Depends(get_db),
):
    existing_role = db.query(Role).filter(
        Role.role_id == role_id
    ).first()

    if existing_role is None:
        raise HTTPException(
            status_code=404,
            detail="Role not found",
        )

    db.delete(existing_role)
    db.commit()

    return {
        "message": "Role deleted successfully",
        "role_id": role_id,
    }