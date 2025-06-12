from connection import Connect, engine
from fastapi import FastAPI, HTTPException, Request, status
from middleware.middleware import JWTAuthMiddleware
from movies.movies import routers
from userAUTH.auth import router

app = FastAPI()
app.add_middleware(JWTAuthMiddleware)

app.include_router(router)
app.include_router(routers)


@app.on_event("startup")
def startup():
    Connect()


@app.on_event("shutdown")
def shutdown_event():
    engine.dispose()
    print("Connection is closed")


@app.get("/")
async def homePage():
    return "Testing"


@app.get("/profile")
def profile(request: Request):
    user = request.state.user
    return {"username": user.username, "email": user.email}
