from typing import List, Optional

from pydantic import BaseModel, EmailStr


class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str


class MovieCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: float = 0.0
    my_review: str
    actors: List[str]
    tags: List[str]
    image: str


class SeriesCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: Optional[float] = 0.0
    my_review: str
    actors: List[str]
    tags: List[str]
    image: str


class LoginCheck(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


class Otp(BaseModel):
    email: EmailStr
    otp: str


class Sendotp(BaseModel):
    email: EmailStr
