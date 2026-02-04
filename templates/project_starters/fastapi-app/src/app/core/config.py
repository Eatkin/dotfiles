from pydantic import BaseModel

class Settings(BaseModel):
    app_name: str = "FastAPI App"
    debug: bool = False

SETTINGS = Settings()
