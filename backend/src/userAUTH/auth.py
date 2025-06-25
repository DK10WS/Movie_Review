import os
from datetime import datetime, timedelta, timezone
from typing import cast

from connection import get_db
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from jose import jwt
from Model import TempStorage, User
from passlib.context import CryptContext
from schemas import LoginCheck, UserCreate
from sqlalchemy.orm import Session

router = APIRouter()

SECRET_KEY = cast(str, os.getenv("SECRET_KEY"))
ALGORITHM = cast(str, os.getenv("ALGORITHM"))
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7
REFRESH_TOKEN_EXPIRE_DAYS = 7

if not SECRET_KEY or not ALGORITHM:
    raise ValueError(
        "SECRET_KEY and ALGORITHM must be set in environment variables")


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=60)
    encode.update({"exp": expire})
    encoded_jwt = jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict, expires_delta: timedelta | None = None):
    encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + \
            timedelta(days=7)  # Default 7 days
    encode.update({"exp": expire})
    encoded_jwt = jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(normal_password: str, hashed_password) -> bool:
    return pwd_context.verify(normal_password, hashed_password)


@router.post("/register")
async def register_user(creds: UserCreate, db: Session = Depends(get_db)):
    email = creds.email.lower()

    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="email_already_registered")

    verified_email = db.query(TempStorage).filter(
        TempStorage.email == email).first()

    if not verified_email:
        raise HTTPException(status_code=403, detail="email_not_verified")

    hashed_pwd = hash_password(creds.password)
    new_user = User(
        username=creds.username,
        fullname=creds.fullname,
        email=email,
        password=hashed_pwd,
        role="admin",
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    db.delete(verified_email)
    db.commit()

    return {"message": "registration_successful"}


@router.post("/login")
async def login(cred: LoginCheck, db: Session = Depends(get_db)):
    email = cred.email.lower()
    print(f"Received login: {email}, {cred.password}")

    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="email_not_found")

    if not verify_password(cred.password, user.password):
        raise HTTPException(status_code=401, detail="incorrect_password")

    access_token = create_access_token(data={"sub": user.username})
    refresh_token = create_refresh_token(data={"sub": user.username})

    return JSONResponse(
        content={
            "message": "login_successful",
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "username": user.username,
            "email": user.email,
        },
        headers={"Authorization": f"Bearer {access_token}"},
        status_code=200,
    )


@router.get("/whoami")
def whoami(request: Request, db: Session = Depends(get_db)):
    user = request.state.user
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return {
        "username": user.username,
        "fullname": user.fullname,
        "email": user.email,
        "role": user.role,
    }


def get_privileges(request: Request):
    user = request.state.user
    return {"role": user.role}


def get_current_user(request: Request) -> User:
    return request.state.user
