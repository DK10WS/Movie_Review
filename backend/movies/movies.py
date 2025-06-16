from connection import get_db
from fastapi import APIRouter, Depends, HTTPException, Request
from Model import Actor, Movie, Series, Tag
from schemas import MovieCreate, SeriesCreate
from sqlalchemy import func
from sqlalchemy.orm import Session
from userAUTH.auth import get_privileges

routers = APIRouter()


@routers.post("/movies")
def add_movie(
    movie: MovieCreate,
    db: Session = Depends(get_db),
    priv: str = Depends(get_privileges),
):
    if priv["role"] != "admin":
        return {"message": "Not AUthorized contact admin"}

    actor_objs = []
    for actor_name in movie.actors:
        actor = db.query(Actor).filter(Actor.name == actor_name).first()
        if not actor:
            actor = Actor(name=actor_name)
            db.add(actor)
            db.flush()
        actor_objs.append(actor)

    tag_objs = []
    for tag_name in movie.tags:
        tag = db.query(Tag).filter(Tag.name == tag_name).first()
        if not tag:
            tag = Tag(name=tag_name)
            db.add(tag)
            db.flush()
        tag_objs.append(tag)

    new_movie = Movie(
        title=movie.title,
        description=movie.description,
        genre=movie.genre,
        rating=movie.rating,
        stars=movie.stars,
        my_review=movie.my_review,
        actors=actor_objs,
        tags=tag_objs,
        image=movie.image,
    )

    db.add(new_movie)
    db.commit()
    db.refresh(new_movie)

    return {"message": "Movie added successfully", "movie_id": new_movie.id}


@routers.post("/series")
def add_series(
    series: SeriesCreate,
    db: Session = Depends(get_db),
    role: str = Depends(get_privileges),
):
    if role != "admin":
        return {"message": "Not AUthorized contact admin"}
    actor_objects = []
    for name in series.actor_names:
        actor = db.query(Actor).filter(
            func.lower(Actor.name) == name.lower()).first()
        if not actor:
            actor = Actor(name=name)
            db.add(actor)
        actor_objects.append(actor)

    tag_objects = []
    for name in series.tag_names:
        tag = db.query(Tag).filter(func.lower(
            Tag.name) == name.lower()).first()
        if not tag:
            tag = Tag(name=name)
            db.add(tag)
        tag_objects.append(tag)

    new_series = Series(
        title=series.title,
        description=series.description,
        genre=series.genre,
        rating=series.rating,
        stars=series.stars,
        my_review=series.my_review,
        actors=actor_objects,
        tags=tag_objects,
        image=series.image,
    )

    db.add(new_series)
    db.commit()
    db.refresh(new_series)

    return {"message": "Series added successfully", "series_id": new_series.id}
