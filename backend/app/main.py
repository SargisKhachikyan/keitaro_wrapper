
import os

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.routes.health import router as health_router
from app.api.routes.campaigns import router as campaigns_router
from app.api.routes.keitaro import router as keitaro_router
from app.api.routes.auth import router as auth_router
from app.core.security import backend_auth
from app.core.rate_limit import rate_limiter


app = FastAPI(
    title="Keitaro Wrapper API",
    description="Backend API for managing Keitaro campaigns and offers",
    version="1.0.0",
)

cors_origins = os.getenv(
    "CORS_ALLOWED_ORIGINS",
    "http://localhost:8765,http://127.0.0.1:8765,http://localhost,http://127.0.0.1",
)
allowed_origins = [
    origin.strip()
    for origin in cors_origins.split(",")
    if origin.strip() and origin.strip() != "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(campaigns_router)
app.include_router(keitaro_router)
app.include_router(auth_router)


PUBLIC_PATHS = {
    "/",
    "/health",
    "/docs",
    "/redoc",
    "/openapi.json",
    "/auth/login",
    "/auth/status",
    "/auth/logout",
}


@app.middleware("http")
async def security_middleware(request: Request, call_next):
    try:
        rate_limiter.check(request)
        if request.url.path not in PUBLIC_PATHS:
            backend_auth.require_request(request)
    except HTTPException as error:
        return JSONResponse(
            status_code=error.status_code,
            content={"detail": error.detail},
        )
    return await call_next(request)


@app.get("/")
def root():
    return {"message": "Keitaro Wrapper API is running"}
