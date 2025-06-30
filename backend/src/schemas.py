from typing import List, Optional

from fastapi import UploadFile
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class MovieOut(BaseModel):
    id: int
    title: str
    stars: float
    genre: str
    image: str

    model_config = {"from_attributes": True}


class RecommendationResponse(BaseModel):
    title: str
    score: float


class SeriesOut(BaseModel):
    id: int
    title: str
    stars: float
    rating: str
    genre: str
    image: str
    year_release: str
    actors: list[str]
    tags: list[str]
    my_review: str

    model_config = ConfigDict(from_attributes=True)


class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str


class CommentCreate(BaseModel):
    movie_id: Optional[int] = None
    series_id: Optional[int] = None
    rating: float = Field(..., ge=0.0, le=10.0)
    comment: Optional[str] = ""


class MovieCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: float = Field(..., ge=0.0, le=10.0)
    my_review: str
    actors: List[str]
    tags: List[str]
    image: UploadFile
    year_release: int


class SeriesCreate(BaseModel):
    title: str
    description: str
    genre: str
    rating: str
    stars: float = Field(..., ge=0.0, le=10.0)
    my_review: str
    actors: List[str]
    tags: List[str]
    image: str
    year_release: int


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
