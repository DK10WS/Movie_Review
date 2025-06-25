from connection import get_db
from fastapi import APIRouter, Depends, HTTPException, Query
from Model import Comment, Movie, Series, User
from schemas import CommentCreate
from sqlalchemy.orm import Session, joinedload
from userAUTH.auth import get_current_user

router = APIRouter()


@router.post("/comment")
def post_comment(
    comment_data: CommentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if (comment_data.movie_id is None) == (comment_data.series_id is None):
        raise HTTPException(
            status_code=400, detail="Specify either movie_id or series_id, not both."
        )

    if comment_data.movie_id:
        movie = db.query(Movie).filter(Movie.id == comment_data.movie_id).first()
        if not movie:
            raise HTTPException(status_code=404, detail="Movie not found.")
    else:
        series = db.query(Series).filter(Series.id == comment_data.series_id).first()
        if not series:
            raise HTTPException(status_code=404, detail="Series not found.")

    new_comment = Comment(
        user_id=current_user.id,
        movie_id=comment_data.movie_id,
        series_id=comment_data.series_id,
        rating=comment_data.rating,
        comment=comment_data.comment,
    )

    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)

    return {"message": "Comment added successfully", "comment_id": new_comment.id}


@router.get("/reviews")
def get_reviews(
    movie_id: int = Query(default=None),
    series_id: int = Query(default=None),
    db: Session = Depends(get_db),
):
    if (movie_id is None) == (series_id is None):
        raise HTTPException(
            status_code=400,
            detail="Provide either movie_id or series_id, not both or neither.",
        )

    query = db.query(Comment).options(joinedload(Comment.user))

    if movie_id:
        movie = db.query(Movie).filter(Movie.id == movie_id).first()
        if not movie:
            raise HTTPException(status_code=404, detail="Movie not found.")
        comments = query.filter(Comment.movie_id == movie_id).all()
    else:
        series = db.query(Series).filter(Series.id == series_id).first()
        if not series:
            raise HTTPException(status_code=404, detail="Series not found.")
        comments = query.filter(Comment.series_id == series_id).all()

    return [
        {
            "username": comment.user.username,
            "rating": comment.rating,
            "comment": comment.comment,
        }
        for comment in comments
    ]


@router.delete("/delete/comment/{comment_id}", status_code=204)
def delete_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    comment = db.query(Comment).filter(Comment.id == comment_id).first()

    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")

    if comment.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="You can only delete your own comments unless you're an admin",
        )

    db.delete(comment)
    db.commit()

    return {"detail": "Comment deleted successfully"}
