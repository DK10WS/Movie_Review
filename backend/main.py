from contextlib import asynccontextmanager

from connection import connect, engine
from fastapi import FastAPI, Request
from middleware.middleware import JWTAuthMiddleware
from movies.movies import routers as movie_routers
from userAUTH.auth import router


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

app.include_router(router)
app.include_router(movie_routers, prefix="/movies", tags=["Movies"])
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
def profile(request: Request):
    user = request.state.user
    return {"username": user.username, "email": user.email}
