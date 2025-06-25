from contextlib import asynccontextmanager

from connection import connect, engine
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from middleware.middleware import JWTAuthMiddleware
from Model import User
from movies.movies import routers as movie_routers
from reviews.reviews import router as rev
from userAUTH.auth import get_current_user, router
from userAUTH.mailService import router as rn
from movies.get_movies import routers as mov


@asynccontextmanager
async def lifespan(app: FastAPI):
    # connect
    connect()
    yield
    # disconnect
    engine.dispose()
    print("Connection is closed")


app = FastAPI(lifespan=lifespan)
app.add_middleware(JWTAuthMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["Authorization"],
)
app.include_router(router)
app.include_router(rev)
app.include_router(mov)
app.include_router(rn)
app.include_router(movie_routers, prefix="/add")

""""
Depricated

@app.on_event("startup")
def startup():
    Connect()


@app.on_event("shutdown")
def shutdown_event():
    engine.dispose()
    print("Connection is closed")

"""


@app.get("/")
async def homePage():
    return "Testing"


@app.get("/profile")
def profile(user: User = Depends(get_current_user)):
    return {
        "username": user.username,
        "email": user.email,
        "id": user.id,
        "role": user.role,
    }
