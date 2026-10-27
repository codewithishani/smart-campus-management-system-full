from datetime import datetime, timedelta, timezone
import os

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from pwdlib import PasswordHash
from sqlalchemy.orm import Session

from database import get_db
from models import Parent, User


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


# =========================
# SECURITY SETTINGS
# =========================

SECRET_KEY = os.getenv(
    "SMART_CAMPUS_SECRET_KEY",
    "smart-campus-development-secret-change-this",
)

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


password_hash = PasswordHash.recommended()


# =========================
# PASSWORD HELPERS
# =========================

def hash_password(password: str) -> str:
    return password_hash.hash(password)


def verify_password(
    plain_password: str,
    hashed_password: str,
) -> bool:
    return password_hash.verify(
        plain_password,
        hashed_password,
    )


# =========================
# LOGIN
# =========================

@router.post("/login")
def login(
    email: str,
    password: str,
    db: Session = Depends(get_db),
):
    user = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    # Passwords should be stored as hashes.
    # During migration, this also supports existing
    # plaintext passwords so existing users can still log in.
    password_valid = False

    if user.password.startswith("$argon2"):
        password_valid = verify_password(
            password,
            user.password,
        )
    else:
        # Existing old password stored directly in DB.
        password_valid = password == user.password

        # Automatically upgrade it to a secure hash.
        if password_valid:
            user.password = hash_password(password)
            db.commit()
            db.refresh(user)

    if not password_valid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    # =========================
    # ROLE INFORMATION
    # =========================

    role_name = None

    if user.role is not None:
        role_name = user.role.role_name

    # =========================
    # CREATE JWT TOKEN
    # =========================

    expire = datetime.now(timezone.utc) + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES
    )

    token_data = {
        "sub": str(user.user_id),
        "email": user.email,
        "role_id": user.role_id,
        "role": role_name,
        "exp": expire,
    }

    access_token = jwt.encode(
        token_data,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )

    response = {
        "message": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.user_id,
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
        "role_id": user.role_id,
        "role": role_name,
    }

    # =========================
    # PARENT INFORMATION
    # =========================

    if role_name and role_name.lower() == "parent":
        parent = (
            db.query(Parent)
            .filter(Parent.user_id == user.user_id)
            .first()
        )

        if parent is not None:
            response["parent_id"] = parent.parent_id

    # =========================
    # STUDENT INFORMATION
    # =========================

    if (
        role_name
        and role_name.lower() == "student"
        and user.student_profile is not None
    ):
        response["student_id"] = (
            user.student_profile.student_id
        )

    # =========================
    # FACULTY INFORMATION
    # =========================

    if (
        role_name
        and role_name.lower() == "faculty"
        and user.faculty_profile is not None
    ):
        response["faculty_id"] = (
            user.faculty_profile.faculty_id
        )

    return response


# =========================
# TOKEN VERIFICATION
# =========================

@router.get("/verify")
def verify_token(
    token: str,
):
    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

        return {
            "valid": True,
            "user_id": int(payload["sub"]),
            "email": payload.get("email"),
            "role_id": payload.get("role_id"),
            "role": payload.get("role"),
        }

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
        )

    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )