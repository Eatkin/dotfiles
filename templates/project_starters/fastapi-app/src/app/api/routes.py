from fastapi import APIRouter

from app.models.placeholder import Placeholder

router = APIRouter()

@router.get("/health")
def health():
    return {"status": "ok"}

@router.get(
    "/placeholder",
    response_model=Placeholder,
    summary="Get placeholder object",
    description=(
        "Returns a static placeholder model. "
        "This endpoint exists as an example of response models, "
        "typing, and FastAPI documentation generation."
    ),
    tags=["examples"],
)
def get_placeholder():
    """
    Example endpoint demonstrating:
    - response_model usage
    - Pydantic serialization
    - automatic OpenAPI docs

    Replace or delete this endpoint in real applications.
    """
    return Placeholder(
        id=1,
        name="example",
        description="this does nothing on purpose"
    )