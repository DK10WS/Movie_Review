from pydantic import BaseModel, EmailStr


class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str


class movies(BaseModel):
    id: int
    title: str
    description: str
    genre: list
    rating: str
    actors: list
    tags: list
    stars: float


class reviews(BaseModel):
    id: int
    user_id: int
    movie_id: int
    my_review: str
    rating: float
    comment: str


class LoginCheck(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str
