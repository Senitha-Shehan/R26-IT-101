import os
import sys
from typing import Optional
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException, status, Depends, Request
from fastapi.security import OAuth2PasswordRequestForm

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.auth.security import (
    verify_password,
    create_access_token,
    get_expert_by_email,
    get_current_expert,
)

router = APIRouter(prefix="/api/auth", tags=["Expert Authentication"])


class LoginRequest(BaseModel):
    email: Optional[str] = None
    username: Optional[str] = None
    password: str


class UserResponse(BaseModel):
    email: str
    name: str
    role: str = "expert"


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


@router.post("/login", response_model=TokenResponse)
async def login(request: Request):
    """
    Login endpoint supporting JSON body or form-data body.
    Accepts 'email' or 'username' alongside 'password'.
    """
    email = None
    password = None

    content_type = request.headers.get("content-type", "")

    if "application/json" in content_type:
        try:
            body = await request.json()
            email = body.get("email") or body.get("username")
            password = body.get("password")
        except Exception:
            pass
    elif "application/x-www-form-urlencoded" in content_type or "multipart/form-data" in content_type:
        try:
            form = await request.form()
            email = form.get("username") or form.get("email")
            password = form.get("password")
        except Exception:
            pass
    else:
        # Fallback payload attempt
        try:
            body = await request.json()
            email = body.get("email") or body.get("username")
            password = body.get("password")
        except Exception:
            pass

    if not email or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email/username and password are required.",
        )

    expert = get_expert_by_email(email)
    if not expert:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    hashed_pw = expert.get("hashed_password", "")
    if not verify_password(password, hashed_pw):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(data={"sub": expert["email"], "role": expert.get("role", "expert")})

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse(
            email=expert["email"],
            name=expert.get("name", "Dr. CropGuard Expert"),
            role=expert.get("role", "expert"),
        ),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_expert: dict = Depends(get_current_expert)):
    return UserResponse(
        email=current_expert["email"],
        name=current_expert.get("name", "Dr. CropGuard Expert"),
        role=current_expert.get("role", "expert"),
    )
