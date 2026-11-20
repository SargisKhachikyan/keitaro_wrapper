from fastapi import APIRouter, Request
from pydantic import BaseModel, Field

from app.core.security import backend_auth


router = APIRouter(prefix="/auth", tags=["Authentication"])


class LoginRequest(BaseModel):
    username: str = Field(min_length=1, max_length=200)
    password: str = Field(min_length=1, max_length=200)


@router.get("/status")
def status():
    return {
        "success": True,
        "enabled": backend_auth.enabled,
    }


@router.post("/login")
def login(data: LoginRequest):
    token = backend_auth.login(data.username, data.password)
    if not token:
        return {"success": True, "authenticated": False}
    return {"success": True, "authenticated": True, "access_token": token}


@router.post("/logout")
def logout(request: Request):
    backend_auth.logout(request)
    return {"success": True}
