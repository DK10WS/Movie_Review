from connection import Base
from sqlalchemy import Column, Float, ForeignKey, Integer, String


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String, unique=True)
    fullname = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)


class Review(Base):
    __tablename__ = "reviews"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    movie_id = Column(Integer, ForeignKey("movies.id"))
    my_review = Column(String)
    rating = Column(Float)
    comment = Column(String)


class Movie(Base):
    __tablename__ = "movies"
    id = Column(Integer, primary_key=True)
    title = Column(String)
    description = Column(String)
    genre = Column(String)
    rating = Column(Float)
