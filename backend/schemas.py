from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str

class LoginCheck(BaseModel):
    email: EmailStr
    password: str

class ReadUser(BaseModel):
    username: str
    fullname: str
    email: str


class Token(BaseModel):
    access_token: str
    token_type: str
