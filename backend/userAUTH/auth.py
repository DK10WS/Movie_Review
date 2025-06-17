import os
from datetime import datetime, timedelta, timezone
from typing import cast

from connection import get_db
from fastapi import APIRouter, Depends, HTTPException, Request, Response
from jose import jwt
from Model import TempStorage, User
from passlib.context import CryptContext
from schemas import LoginCheck, UserCreate
from sqlalchemy.orm import Session

router = APIRouter()

SECRET_KEY = cast(str, os.getenv("SECRET_KEY"))
ALGORITHM = cast(str, os.getenv("ALGORITHM"))
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7

if not SECRET_KEY or not ALGORITHM:
    raise ValueError("SECRET_KEY and ALGORITHM must be set in environment variables")


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
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
    existing_user = db.query(User).filter(User.email == creds.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    verified_email = (
        db.query(TempStorage).filter(TempStorage.email == creds.email).first()
    )
    if not verified_email:
        raise HTTPException(
            status_code=403,
            detail="Email not verified. Please verify via the link sent to your email.",
        )

    hashed_pwd = hash_password(creds.password)
    new_user = User(
        username=creds.username,
        fullname=creds.fullname,
        email=creds.email,
        password=hashed_pwd,
        role="user",
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    db.delete(verified_email)
    db.commit()

    return {"message": f"{new_user.fullname}, you are registered successfully."}


@router.post("/login")
async def login(cred: LoginCheck, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.email == cred.email).first()

    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")

    if not verify_password(cred.password, user.password):
        raise HTTPException(status_code=400, detail="Password is incorrect")

    access_token = create_access_token(data={"sub": user.username})
    jwt = {"Authorization": f"Bearer {access_token}"}

    return Response(headers=jwt)


def get_privileges(request: Request) -> dict:
    user = request.state.user
    return {"role": user.role}
