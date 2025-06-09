from fastapi import FastAPI,HTTPException,status
from userAUTH.auth import router

app = FastAPI()
app.include_router(router)

@app.get("/")
async def homePage():
    return "Testing"
