import os
import sys
import bcrypt
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt
from dotenv import load_dotenv

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

load_dotenv()

from database.mongodb import get_mongo_client, MONGODB_DATABASE

JWT_SECRET = os.getenv("JWT_SECRET", "cropguard_secret_key_research_2026_expert_portal_auth_key")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "480"))

EXPERT_DEFAULT_EMAIL = os.getenv("EXPERT_DEFAULT_EMAIL", "expert@cropguard.org")
EXPERT_DEFAULT_PASSWORD = os.getenv("EXPERT_DEFAULT_PASSWORD", "ExpertGuard#2026")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        if isinstance(plain_password, str):
            plain_bytes = plain_password.encode("utf-8")
        else:
            plain_bytes = plain_password

        if isinstance(hashed_password, str):
            hash_bytes = hashed_password.encode("utf-8")
        else:
            hash_bytes = hashed_password

        return bcrypt.checkpw(plain_bytes, hash_bytes)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    if isinstance(password, str):
        password_bytes = password.encode("utf-8")
    else:
        password_bytes = password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode("utf-8")


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "iat": now})
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)
    return encoded_jwt


def get_experts_collection():
    client = get_mongo_client()
    if client is not None:
        db = client[MONGODB_DATABASE]
        return db["experts"]
    return None


def get_expert_by_email(email: str) -> Optional[Dict[str, Any]]:
    email_clean = email.strip().lower()
    collection = get_experts_collection()

    if collection is not None:
        try:
            user = collection.find_one({"email": email_clean})
            if user:
                return user
        except Exception:
            pass

    # Default fallback account seeding / matching
    if email_clean == EXPERT_DEFAULT_EMAIL.lower():
        default_hash = get_password_hash(EXPERT_DEFAULT_PASSWORD)
        default_user = {
            "email": EXPERT_DEFAULT_EMAIL.lower(),
            "name": "Dr. CropGuard Expert",
            "hashed_password": default_hash,
            "role": "expert",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        if collection is not None:
            try:
                collection.update_one(
                    {"email": email_clean},
                    {"$setOnInsert": default_user},
                    upsert=True
                )
                db_user = collection.find_one({"email": email_clean})
                if db_user:
                    return db_user
            except Exception:
                pass
        return default_user
    return None


async def get_current_expert(token: Optional[str] = Depends(oauth2_scheme)) -> Dict[str, Any]:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate authentication credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if not token:
        raise credentials_exception
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception

    expert = get_expert_by_email(email)
    if expert is None:
        raise credentials_exception
    return expert
