import smtplib

import pyotp
from connection import get_db
from fastapi import APIRouter, Depends, HTTPException
from Model import User, VerifyUser
from schemas import Otp, Sendotp
from sqlalchemy.orm import Session

router = APIRouter()


@router.post("/otpvalidate")
async def otpvalidation(otp: Otp, db: Session = Depends(get_db)):
    otp_record = db.query(VerifyUser).filter(
        VerifyUser.email == otp.email).first()

    if not otp_record:
        raise HTTPException(
            status_code=400, detail="Email does not exist. Register first."
        )

    totp = pyotp.TOTP(otp_record.secret)
    is_valid = totp.verify(otp.otp, valid_window=20)

    if not is_valid:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    user = db.query(User).filter(User.email == otp.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.verified = True
    db.delete(otp_record)
    db.commit()

    return {"message": f"OTP verified. {user.email} is now verified."}


async def generate_otp() -> dict[str:str]:
    secret = pyotp.random_base32()
    print(secret, pyotp.TOTP(secret).now())
    return {"otp": pyotp.TOTP(secret).now(), "secret": secret}


@router.post("/sendotp")
async def send_mail(email: Sendotp, db: Session = Depends(get_db)) -> str:
    sender = "email@gmail.com"
    password = "find from google security"
    receiver = email.email

    otp_data = await generate_otp()
    otp = otp_data["otp"]
    secret = otp_data["secret"]

    message = f"Subject: OTP Verification\n\nYour OTP is {otp}."
    print(message)

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(sender, password)
            server.sendmail(sender, receiver, message)
    except Exception as e:
        print(f"Failed to send email: {e}")
        raise HTTPException(status_code=500, detail="Failed to send email")

    user = db.query(User).filter(User.email == email.email).first()
    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")
    if user.verified:
        raise HTTPException(status_code=400, detail="User Already verified")

    existing_otp = db.query(VerifyUser).filter(
        VerifyUser.email == email.email).first()
    if existing_otp:
        db.delete(existing_otp)

    new_otp = VerifyUser(email=email.email, secret=secret)
    db.add(new_otp)
    db.commit()
    db.refresh(new_otp)

    return f"OTP sent to {email.email}"
