from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from userAUTH.connection import get_db
from schemas import UserCreate
from userAUTH.Model import User

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

@router.post("/register/")

def register_user(creds: UserCreate, db: Session = Depends(get_db)):

    existing_user = db.query(User).filter(User.email == creds.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pwd = hash_password(creds.password)

    new_user = User(
        username=creds.username,
        fullname=creds.fullname,
        email=creds.email,
        password=hashed_pwd
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
