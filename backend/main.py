from fastapi import FastAPI

from app.api.routes.health import router as health_router
from app.core.database import Base, engine
from app.models.campaign import Campaign

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Keitaro Wrapper API",
    description="Backend API for managing Keitaro campaigns and offers",
    version="1.0.0",
)

app.include_router(health_router)


@app.get("/")
def root():
    return {"message": "Keitaro Wrapper API is running"}