from fastapi import APIRouter, HTTPException

routers = APIRouter()


@routers.post("/movies/add")
def add_movies():
    pass
