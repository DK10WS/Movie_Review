from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    username: str
    fullname: str
    email: EmailStr
    password: str
