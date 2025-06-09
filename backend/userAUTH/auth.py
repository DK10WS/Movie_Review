from datetime import datetime_CAPI
from fastapi import FastAPI,HTTPException,status, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from schemas import UserCreate


router = APIRouter()

@router.post("/register/")
async def test(creds: UserCreate):
   return creds.password
