from connection import Base
from sqlalchemy import (CheckConstraint, Column, Float, ForeignKey, Integer,
                        String, Table, Text, Boolean)
from sqlalchemy.orm import relationship

movie_actor = Table(
    "movie_actor",
    Base.metadata,
    Column("movie_id", ForeignKey("movies.id"), primary_key=True),
    Column("actor_id", ForeignKey("actors.id"), primary_key=True),
)

series_actor = Table(
    "series_actor",
    Base.metadata,
    Column("series_id", ForeignKey("series.id"), primary_key=True),
    Column("actor_id", ForeignKey("actors.id"), primary_key=True),
)

movie_tag = Table(
    "movie_tag",
    Base.metadata,
    Column("movie_id", ForeignKey("movies.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
)

series_tag = Table(
    "series_tag",
    Base.metadata,
    Column("series_id", ForeignKey("series.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
)


class VerifyUser(Base):
    __tablename__ = "otp"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, nullable=False)
    secret = Column(String, nullable=False)


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String, unique=True, nullable=False)
    fullname = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    role = Column(String, nullable=False)
    verified = Column(Boolean, nullable=False)

    comments = relationship("Comment", back_populates="user")


class Movie(Base):
    __tablename__ = "movies"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    genre = Column(String)
    rating = Column(String)
    stars = Column(Float, default=0.0)
    my_review = Column(Text)
    image = Column(Text)

    actors = relationship("Actor", secondary=movie_actor,
                          back_populates="movies")
    tags = relationship("Tag", secondary=movie_tag, back_populates="movies")
    comments = relationship("Comment", back_populates="movie")


class Series(Base):
    __tablename__ = "series"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    genre = Column(String)
    rating = Column(String)
    stars = Column(Float, default=0.0)
    my_review = Column(Text)
    image = Column(Text)

    actors = relationship("Actor", secondary=series_actor,
                          back_populates="series")
    tags = relationship("Tag", secondary=series_tag, back_populates="series")
    comments = relationship("Comment", back_populates="series")


class Actor(Base):
    __tablename__ = "actors"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)

    movies = relationship("Movie", secondary=movie_actor,
                          back_populates="actors")
    series = relationship("Series", secondary=series_actor,
                          back_populates="actors")


class Tag(Base):
    __tablename__ = "tags"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)

    movies = relationship("Movie", secondary=movie_tag, back_populates="tags")
    series = relationship("Series", secondary=series_tag,
                          back_populates="tags")


class Comment(Base):
    __tablename__ = "comments"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    movie_id = Column(Integer, ForeignKey("movies.id"), nullable=True)
    series_id = Column(Integer, ForeignKey("series.id"), nullable=True)
    rating = Column(Float, nullable=False)
    comment = Column(Text)

    user = relationship("User", back_populates="comments")
    movie = relationship("Movie", back_populates="comments")
    series = relationship("Series", back_populates="comments")

    __table_args__ = (
        CheckConstraint(
            "(movie_id IS NOT NULL AND series_id IS NULL) OR (movie_id IS NULL AND series_id IS NOT NULL)",
            name="only_one_target",
        ),
    )
