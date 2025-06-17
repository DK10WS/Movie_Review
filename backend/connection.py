import os

from dotenv import load_dotenv
from sqlalchemy import  create_engine, text
from sqlalchemy.orm import declarative_base, sessionmaker

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

    print("Tables in metadata:", Base.metadata.tables.keys())
    Base.metadata.create_all(bind=engine)
    # Base.metadata.drop_all(bind=engine)
    # with engine.connect() as conn:
    #     conn.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
    #     conn.commit()
    #     print("DB Cleaned")


def get_db():
    db = session_local()
    try:
        yield db
    finally:
        db.close()
