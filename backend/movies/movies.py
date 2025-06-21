from connection import get_db
from fastapi import (APIRouter, Depends, File, Form, HTTPException, Request,
                     UploadFile)
from Model import Actor, Movie, Series, Tag
from movies.s3 import upload_image_to_s3
from sqlalchemy import func
from sqlalchemy.orm import Session
from userAUTH.auth import get_privileges

routers = APIRouter()


@routers.post("/movies")
async def add_movie(
    title: str = Form(...),
    description: str = Form(...),
    genre: str = Form(...),
    rating: str = Form(...),
    stars: float = Form(...),
    my_review: str = Form(...),
    actors: list[str] = Form(...),
    tags: list[str] = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    priv: dict = Depends(get_privileges),
):
    if priv["role"] != "admin":
        return {"message": "Not Authorized contact admin"}

    try:
        image_url = await upload_image_to_s3(image)
    except Exception as e:
        return {"error": str(e)}

    actor_objs = []
    for actor_name in actors:
        actor = db.query(Actor).filter(Actor.name == actor_name).first()
        if not actor:
            actor = Actor(name=actor_name)
            db.add(actor)
            db.flush()
        actor_objs.append(actor)

    tag_objs = []
    for tag_name in tags:
        tag = db.query(Tag).filter(Tag.name == tag_name).first()
        if not tag:
            tag = Tag(name=tag_name)
            db.add(tag)
            db.flush()
        tag_objs.append(tag)

    new_movie = Movie(
        title=title,
        description=description,
        genre=genre,
        rating=rating,
        stars=stars,
        my_review=my_review,
        actors=actor_objs,
        tags=tag_objs,
        image=image_url,
    )

    db.add(new_movie)
    db.commit()
    db.refresh(new_movie)

    return {"message": "Movie added successfully", "movie_id": new_movie.id}


@routers.post("/series")
async def add_series(
    title: str = Form(...),
    description: str = Form(...),
    genre: str = Form(...),
    rating: str = Form(...),
    stars: float = Form(...),
    my_review: str = Form(...),
    actor_names: list[str] = Form(...),
    tag_names: list[str] = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
    priv: dict = Depends(get_privileges),
):
    if priv["role"] != "admin":
        return {"message": "Not Authorized contact admin"}

    try:
        image_url = await upload_image_to_s3(image)
    except Exception as e:
        return {"error": str(e)}

    actor_objects = []
    for name in actor_names:
        actor = db.query(Actor).filter(func.lower(Actor.name) == name.lower()).first()
        if not actor:
            actor = Actor(name=name)
            db.add(actor)
            db.flush()
        actor_objects.append(actor)

    tag_objects = []
    for name in tag_names:
        tag = db.query(Tag).filter(func.lower(Tag.name) == name.lower()).first()
        if not tag:
            tag = Tag(name=name)
            db.add(tag)
            db.flush()
        tag_objects.append(tag)

    new_series = Series(
        title=title,
        description=description,
        genre=genre,
        rating=rating,
        stars=stars,
        my_review=my_review,
        actors=actor_objects,
        tags=tag_objects,
        image=image_url,
    )

    db.add(new_series)
    db.commit()
    db.refresh(new_series)

    return {
        "message": "Series added successfully",
        "series_id": new_series.id,
        "image_url": image_url,
    }
