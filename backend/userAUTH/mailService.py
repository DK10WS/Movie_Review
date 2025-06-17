import hashlib
import os
import smtplib
import typing

import redis
from starlette.routing import Host
from connection import get_db
from fastapi import APIRouter, Depends, HTTPException
from Model import TempStorage, User
from schemas import Sendotp
from sqlalchemy.orm import Session

URL = os.getenv("URL")
PASSWORD = os.getenv("PASSWORD", "")
EMAIL = os.getenv("EMAIL", "")
HOST = os.getenv("LOCALHOST", "")
PORT = typing.cast(int, os.getenv("PORT"))


if not URL or not PASSWORD or not EMAIL or not Host:
    raise ValueError("Env variables missing")

router = APIRouter()

redis_client = redis.Redis(host=HOST, port=PORT, db=0, decode_responses=True)


def email_hash(email: str) -> str:
    return hashlib.sha256(email.encode()).hexdigest()


def create_link(hashed_email: str) -> str:
    return f"{URL}/verifyOTP/{hashed_email}"


def send_email(email: str, link: str):
    sender = EMAIL
    password = PASSWORD
    receiver = email

    message = f"Subject: Account Verification\n\nClick on this link to verify your acc OTP {
        link}."
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender, password)
        server.sendmail(sender, receiver, message)


@router.post("/sendotp")
def sendOTP(email: Sendotp, db: Session = Depends(get_db)):

    if not email.email:
        raise HTTPException(status_code=400, detail="Email is required")

    check_email = db.query(TempStorage).filter(
        TempStorage.email == email.email).first()
    existing_user = db.query(User).filter(User.email == email.email).first()

    if check_email or existing_user:
        raise HTTPException(status_code=409, detail="Email already verified")

    hashed_email = email_hash(email.email)

    if redis_client.get(hashed_email):
        return {"message": "Verification link already sent. Please check your email."}

    redis_client.set(hashed_email, email.email)
    redis_client.expire(hashed_email, 600)

    link = create_link(hashed_email)
    try:
        send_email(email.email, link)
    except Exception as e:
        redis_client.delete(hashed_email)
        raise HTTPException(
            status_code=500, detail=f"Failed to send email: {str(e)}")

    return {"message": f"Verification link sent to {email.email}"}


@router.get("/verifyOTP/{email_hash}")
def verifyOTP(email_hash: str, db: Session = Depends(get_db)):

    if not email_hash:
        raise HTTPException(status_code=400, detail="Email hash is required")

    email = redis_client.get(email_hash)
    if email is None:
        raise HTTPException(
            status_code=404, detail="Invalid or expired verification link"
        )

    existing_email = db.query(TempStorage).filter(
        TempStorage.email == email).first()
    if existing_email:
        return {"message": "Email already verified"}

    new_email = TempStorage(email=email)
    db.add(new_email)
    db.commit()
    db.refresh(new_email)

    redis_client.delete(email_hash)

    return {"message": "Email verified successfully", "email": email}
