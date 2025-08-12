from typing import List, Optional

from fastapi import (APIRouter, Depends, File, Form, HTTPException, Request,
                     UploadFile)
from sqlalchemy import func
from sqlalchemy.orm import Session

from connection import get_db
from Model import Actor, Movie, Series, Tag
from movies.s3 import upload_image_to_s3
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
    year_release: str = Form(...),
    language: str = Form(...),
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
        language=language,
        year_release=year_release,
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
    language: str = Form(...),
    year_release: str = Form(...),
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
        year_release=year_release,
        language=language,
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


@routers.patch("/edit_movies")
async def edit_movie_by_title_year(
    title: str = Form(...),
    year_release: str = Form(...),
    new_title: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    genre: Optional[str] = Form(None),
    rating: Optional[str] = Form(None),
    stars: Optional[float] = Form(None),
    my_review: Optional[str] = Form(None),
    language: Optional[str] = Form(None),
    actors: Optional[List[str]] = Form(None),
    tags: Optional[List[str]] = Form(None),
    image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    priv: dict = Depends(get_privileges),
):
    if priv["role"] != "admin":
        return {"message": "Not Authorized contact admin"}

    movie = (
        db.query(Movie)
        .filter(Movie.title == title, Movie.year_release == year_release)
        .first()
    )

    if not movie:
        return {"error": "Movie not found"}

    if new_title is not None:
        movie.title = new_title
    if description is not None:
        movie.description = description
    if genre is not None:
        movie.genre = genre
    if rating is not None:
        movie.rating = rating
    if stars is not None:
        movie.stars = stars
    if my_review is not None:
        movie.my_review = my_review
    if language is not None:
        movie.language = language

    if image is not None:
        try:
            image_url = await upload_image_to_s3(image)
            movie.image = image_url
        except Exception as e:
            return {"error": str(e)}

    if actors is not None:
        actor_objs = []
        for actor_name in actors:
            actor = db.query(Actor).filter(Actor.name == actor_name).first()
            if not actor:
                actor = Actor(name=actor_name)
                db.add(actor)
                db.flush()
            actor_objs.append(actor)
        movie.actors = actor_objs

    if tags is not None:
        tag_objs = []
        for tag_name in tags:
            tag = db.query(Tag).filter(Tag.name == tag_name).first()
            if not tag:
                tag = Tag(name=tag_name)
                db.add(tag)
                db.flush()
            tag_objs.append(tag)
        movie.tags = tag_objs

    db.commit()
    db.refresh(movie)

    return {
        "message": "Movie updated successfully",
        "movie_title": movie.title,
    }


@routers.patch("/edit_series")
async def edit_series(
    title: str = Form(...),
    year_release: str = Form(...),
    new_title: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    genre: Optional[str] = Form(None),
    rating: Optional[str] = Form(None),
    stars: Optional[float] = Form(None),
    my_review: Optional[str] = Form(None),
    language: Optional[str] = Form(None),
    actor_names: Optional[List[str]] = Form(None),
    tag_names: Optional[List[str]] = Form(None),
    image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    priv: dict = Depends(get_privileges),
):
    if priv["role"] != "admin":
        return {"message": "Not Authorized contact admin"}

    series = (
        db.query(Series)
        .filter(Series.title == title, Series.year_release == year_release)
        .first()
    )

    if not series:
        return {"error": "Movie not found"}

    if new_title is not None:
        series.title = new_title
    if description is not None:
        series.description = description
    if genre is not None:
        series.genre = genre
    if rating is not None:
        series.rating = rating
    if stars is not None:
        series.stars = stars
    if my_review is not None:
        series.my_review = my_review
    if language is not None:
        series.language = language

    if image is not None:
        try:
            image_url = await upload_image_to_s3(image)
            series.image = image_url
        except Exception as e:
            return {"error": str(e)}

    if actor_names is not None:
        actor_objs = []
        for actor_name in actor_names:
            actor = db.query(Actor).filter(Actor.name == actor_name).first()
            if not actor:
                actor = Actor(name=actor_name)
                db.add(actor)
                db.flush()
            actor_objs.append(actor)
        series.actors = actor_objs

    if tag_names is not None:
        tag_objs = []
        for tag_name in tag_names:
            tag = db.query(Tag).filter(Tag.name == tag_name).first()
            if not tag:
                tag = Tag(name=tag_name)
                db.add(tag)
                db.flush()
            tag_objs.append(tag)
        series.tags = tag_objs

    db.commit()
    db.refresh(series)

    return {
        "message": "Series updated successfully",
        "series": series.title,
    }
