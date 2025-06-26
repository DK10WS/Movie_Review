from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from connection import get_db
from Model import Movie, Series
from schemas import MovieOut, SeriesOut

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
            "year_release": movie.year_release,
            "language": movie.language,
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
            "year_release": series.year_release,
            "language": series.language,
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
        "year_release": movie.year_release,
        "language": movie.language,
    }


@routers.get("/get_series/{series_id}")
def get_series_details(series_id: int, db: Session = Depends(get_db)):
    movie = db.query(Series).filter(Series.id == series_id).first()
    if not movie:
        raise HTTPException(status_code=404, detail="Series not found")

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
        "year_release": movie.year_release,
        "language": movie.language,
    }


@routers.get("/search")
def search(query: str, db: Session = Depends(get_db)):
    movie_results = db.query(Movie).filter(
        Movie.title.ilike(f"%{query}%")).all()
    series_results = db.query(Series).filter(
        Series.title.ilike(f"%{query}%")).all()

    movie_data = [
        {"type": "movie", **MovieOut.model_validate(m).model_dump()}
        for m in movie_results
    ]
    series_data = [
        {"type": "series", **MovieOut.model_validate(s).model_dump()}
        for s in series_results
    ]

    return movie_data + series_data


@routers.get("/series/top_by_language")
def get_top_series_by_language(db: Session = Depends(get_db)):
    series_list = db.query(Series).order_by(Series.stars.desc()).all()

    lang_map = {}

    for show in series_list:
        lang = show.language or "Unknown"
        if lang not in lang_map:
            lang_map[lang] = []

        if len(lang_map[lang]) < 20:
            show_data = {
                "id": show.id,
                "title": show.title,
                "stars": show.stars,
                "rating": show.rating,
                "genre": show.genre,
                "image": show.image,
                "year_release": show.year_release,
                "actors": [a.name for a in show.actors],
                "tags": [t.name for t in show.tags],
                "my_review": show.my_review,
            }
            lang_map[lang].append(show_data)

    return lang_map
