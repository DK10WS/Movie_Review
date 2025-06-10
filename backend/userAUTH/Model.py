from sqlalchemy import Column, Integer, String
from .connection import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True,autoincrement=True)
    username = Column(String, unique=True)
    fullname = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
