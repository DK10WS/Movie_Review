from fastapi import FastAPI, HTTPException, Request, status
from userAUTH.auth import router
from userAUTH.connection import Connect, engine
from userAUTH.middleware import JWTAuthMiddleware

app = FastAPI()
app.add_middleware(JWTAuthMiddleware)
app.include_router(router)

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
