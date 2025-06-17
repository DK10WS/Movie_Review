import os

from connection import get_db
from fastapi import Depends
from jose import JWTError, jwt
from Model import User
from sqlalchemy.orm import Session
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

EXCLUDE_PATHS = [
    "/login",
    "/register",
    "/docs",
    "/openapi.json",
    "/sendotp",
    "/otpvalidate",
]


class JWTAuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        path = request.url.path

        if any(path.startswith(ep) for ep in EXCLUDE_PATHS):
            return await call_next(request)

        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return JSONResponse(
                status_code=401,
                content={"detail": "Authorization header missing or wrong"},
            )

        token = auth_header.split(" ")[1]

        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            username = payload.get("sub")
            if username is None:
                raise ValueError("username is missing in the token")
        except (JWTError, ValueError):
            return JSONResponse(
                status_code=401, content={"detail": "invalid or expired token"}
            )

        try:
            db: Session = next(get_db())
            user = db.query(User).filter(User.username == username).first()
            if not user:
                return JSONResponse(
                    status_code=404, content={"detail": "User not in db"}
                )
            request.state.user = user

        except Exception as e:
            return JSONResponse(
                status_code=500, content={"detail": f"Internal server error: {str(e)}"}
            )
        print(request.state.user)
        return await call_next(request)
