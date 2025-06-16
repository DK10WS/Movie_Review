import os

from dotenv import load_dotenv
from sqlalchemy import Column, Integer, String, create_engine, text
from sqlalchemy.orm import Session, declarative_base, sessionmaker

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if DATABASE_URL is None:
    raise ValueError("DATABASE_URL not found in .env file")

engine = create_engine(DATABASE_URL)

session_local = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()


def connect():
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print(" Database connected:", result.scalar())
    except Exception as e:
        print(" Database connection failed:", e)

    Base.metadata.create_all(bind=engine)


def get_db():
    db = session_local()
    try:
        yield db
    finally:
        db.close()
