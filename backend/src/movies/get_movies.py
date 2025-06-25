from connection import get_db
from fastapi import APIRouter, Depends, HTTPException
from Model import Movie, Series
from sqlalchemy.orm import Session

routers = APIRouter()


@routers.get("/movies/top")
def get_top_movies(db: Session = Depends(get_db)):
    top_movies = db.query(Movie).order_by(Movie.stars.desc()).limit(10).all()

    return [
        {
            "id": movie.id,
            "title": movie.title,
            "stars": movie.stars,
            "rating": movie.rating,
            "genre": movie.genre,
            "image": movie.image,
        }
        for movie in top_movies
    ]


@routers.get("/series/top")
def get_top_series(db: Session = Depends(get_db)):
    top_series = db.query(Series).order_by(Series.stars.desc()).limit(10).all()

    return [
        {
            "id": series.id,
            "title": series.title,
            "stars": series.stars,
            "rating": series.rating,
            "genre": series.genre,
            "image": series.image,
        }
        for series in top_series
    ]


@routers.get("/get_movies/{movie_id}")
def get_movie_details(movie_id: int, db: Session = Depends(get_db)):
    movie = db.query(Movie).filter(Movie.id == movie_id).first()
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")

    return {
        "id": movie.id,
        "title": movie.title,
        "description": movie.description,
        "genre": movie.genre,
        "rating": movie.rating,
        "stars": movie.stars,
        "my_review": movie.my_review,
        "actors": [actor.name for actor in movie.actors],
        "tags": [tag.name for tag in movie.tags],
        "image": movie.image,
    }
