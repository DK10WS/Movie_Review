from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from userAUTH.connection import get_db
from schemas import UserCreate , LoginCheck
from userAUTH.Model import User

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(normal_password, hashed_password):
    return pwd_context.verify(normal_password, hashed_password)

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
    return {"Message" : new_user.fullname + "You are Registered"}

@router.post("/login")
def login(cred: LoginCheck, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == cred.email).first()

    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")

    if not verify_password(cred.password, user.password):
        raise HTTPException(status_code=400, detail="Password is incorrect")

    return {"message": "Logged in GG"}
