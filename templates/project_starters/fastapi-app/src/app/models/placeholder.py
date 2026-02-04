from pydantic import BaseModel
from typing import Optional

class Placeholder(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
