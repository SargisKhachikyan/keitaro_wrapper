import os
import secrets
import time
from threading import Lock

from fastapi import HTTPException, Request, status


class BackendAuth:
    def __init__(self) -> None:
        self.enabled = os.getenv("BACKEND_AUTH_ENABLED", "false").lower() == "true"
        self.username = os.getenv("BACKEND_AUTH_USERNAME", "")
        self.password = os.getenv("BACKEND_AUTH_PASSWORD", "")
        self._tokens: dict[str, float] = {}
        self._lock = Lock()
        self.ttl_seconds = 8 * 60 * 60

    def login(self, username: str, password: str) -> str:
        if not self.enabled:
            return ""
        if not self.username or not self.password:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Backend authentication is not configured.",
            )
        valid = (
            secrets.compare_digest(username, self.username)
            and secrets.compare_digest(password, self.password)
        )
        if not valid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid username or password.",
            )
        token = secrets.token_urlsafe(32)
        with self._lock:
            self._tokens[token] = time.monotonic() + self.ttl_seconds
        return token

    def logout(self, request: Request) -> None:
        token = self._get_token(request)
        if token:
            with self._lock:
                self._tokens.pop(token, None)

    def require_request(self, request: Request) -> None:
        if not self.enabled:
            return
        token = self._get_token(request)
        if not token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication required.",
            )
        now = time.monotonic()
        with self._lock:
            expires = self._tokens.get(token)
            if expires is None or expires <= now:
                self._tokens.pop(token, None)
                expires = None
        if expires is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Session expired. Please sign in again.",
            )

    def purge_expired(self) -> None:
        now = time.monotonic()
        with self._lock:
            expired = [
                token
                for token, expires in self._tokens.items()
                if expires <= now
            ]
            for token in expired:
                self._tokens.pop(token, None)

    @staticmethod
    def _get_token(request: Request) -> str:
        authorization = request.headers.get("Authorization", "")
        if authorization.startswith("Bearer "):
            return authorization[7:].strip()
        return ""


backend_auth = BackendAuth()
