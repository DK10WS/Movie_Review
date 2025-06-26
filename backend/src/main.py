from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from connection import connect, engine
from middleware.middleware import JWTAuthMiddleware
from movies.get_movies import routers as mov
from movies.movies import routers as movie_routers
from reviews.reviews import router as rev
from userAUTH.auth import router
from userAUTH.mailService import router as rn


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
app.include_router(router, prefix="/api")
app.include_router(rev, prefix="/api")
app.include_router(mov, prefix="/api")
app.include_router(rn, prefix="/api")
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
