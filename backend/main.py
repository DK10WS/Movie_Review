from fastapi import FastAPI,HTTPException,status
from userAUTH.auth import router
from userAUTH.connection import Connect
from userAUTH.connection import engine

app = FastAPI()

@app.on_event("startup")
def startup():
    Connect()

app.include_router(router)


@app.on_event("shutdown")
def shutdown_event():
    engine.dispose()
    print("Connection is closed")

@app.get("/")
async def homePage():
    return "Testing"
