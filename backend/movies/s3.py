import os
import shutil
from os import getenv
from tempfile import NamedTemporaryFile
from uuid import uuid4

from dotenv import load_dotenv
from fastapi import UploadFile
from minio import Minio
from minio.error import S3Error

load_dotenv()

endpoint = getenv("ENDPOINT", "s3.whyredfire.tech")
secret_key = getenv("MINIO_SECRET_KEY")
access_key = getenv("MINIO_ACCESS_KEY")
bucket_name = getenv("BUCKETNAME", "movie")

client = Minio(
    endpoint=endpoint, access_key=access_key, secret_key=secret_key, secure=True
)


async def upload_image_to_s3(image: UploadFile) -> str:

    filename = image.filename
    if not filename:
        raise ValueError("No filename provided.")

    extension = filename.split(".")[-1].lower()
    if extension not in ["jpg", "jpeg", "png"]:
        raise ValueError("Invalid image type. Only jpg, jpeg, png allowed.")

    image_key = f"{uuid4()}.{extension}"
    tmp_path = None
    try:
        with NamedTemporaryFile(delete=False, suffix=f".{extension}") as tmp:
            shutil.copyfileobj(image.file, tmp)
            tmp_path = tmp.name

        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)

        client.fput_object(
            bucket_name,
            image_key,
            tmp_path,
        )

    except S3Error as e:
        raise RuntimeError(f"Upload failed: {e}")
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)

    url = client.presigned_get_object(bucket_name, image_key)
    return url
