from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field


class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str


class CommentCreate(BaseModel):
    movie_id: Optional[int] = None
    series_id: Optional[int] = None
    rating: float = Field(..., ge=0.0, le=5.0)
    comment: Optional[str] = ""


class MovieCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: float = Field(..., ge=0.0, le=5.0)
    my_review: str
    actors: List[str]
    tags: List[str]
    image: str


class SeriesCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: float = Field(..., ge=0.0, le=5.0)
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
