import hashlib
import smtplib

import redis
from connection import get_db
from fastapi import APIRouter, Depends, HTTPException
from Model import TempStorage, User
from schemas import Sendotp
from sqlalchemy.orm import Session

router = APIRouter()


def email_hash(email: str) -> str:
    return hashlib.sha256(email.encode()).hexdigest()


def create_link(hashed_email: str) -> str:
    return f"http://127.0.0.1:8000/verifyOTP/{hashed_email}"


def send_email(email: str, link: str):
    sender = "enter your own"
    password = "get from google security app"
    receiver = email

    message = f"Subject: Account Verification\n\nClick on this link to verify your acc OTP {
        link}."
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender, password)
        server.sendmail(sender, receiver, message)


def connect() -> redis.Redis:
    return redis.Redis(host="localhost", port=6379, db=0)


def disconnect(r: redis.Redis):
    r.close()


@router.post("/sendotp")
def sendOTP(email: Sendotp, db: Session = Depends(get_db)):

    if not email.email:
        raise HTTPException(status_code=400, detail="Email is required")

    check_email = db.query(TempStorage).filter(TempStorage.email == email.email).first()
    existing_user = db.query(User).filter(User.email == email.email).first()

    if check_email or existing_user:
        raise HTTPException(status_code=409, detail="Email already verified")

    r = connect()
    hashed_email = email_hash(email.email)

    if r.get(hashed_email):
        disconnect(r)
        return {"message": "Verification link already sent. Please check your email."}

    r.set(hashed_email, email.email)
    r.expire(hashed_email, 600)

    link = create_link(hashed_email)
    try:
        send_email(email.email, link)
    except Exception as e:
        r.delete(hashed_email)
        disconnect(r)
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")

    disconnect(r)
    return {"message": f"Verification link sent to {email.email}"}


@router.get("/verifyOTP/{email_hash}")
def verifyOTP(email_hash: str, db: Session = Depends(get_db)):
    r = connect()

    if not email_hash:
        disconnect(r)
        raise HTTPException(status_code=400, detail="Email hash is required")

    email = r.get(email_hash)
    if email is None:
        disconnect(r)
        raise HTTPException(
            status_code=404, detail="Invalid or expired verification link"
        )
    if isinstance(email, bytes):
        email = email.decode()

    existing_email = db.query(TempStorage).filter(TempStorage.email == email).first()
    if existing_email:
        disconnect(r)
        return {"message": "Email already verified"}

    new_email = TempStorage(email=email)
    db.add(new_email)
    db.commit()
    db.refresh(new_email)

    r.delete(email_hash)
    disconnect(r)

    return {"message": "Email verified successfully", "email": email}
