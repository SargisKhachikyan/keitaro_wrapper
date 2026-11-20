import os
import time
from collections import defaultdict
from threading import Lock

from fastapi import HTTPException, Request, status


class RateLimiter:
    def __init__(self) -> None:
        self.requests_per_minute = int(
            os.getenv("RATE_LIMIT_REQUESTS_PER_MINUTE", "120")
        )
        self.login_requests_per_minute = int(
            os.getenv("RATE_LIMIT_LOGIN_PER_MINUTE", "10")
        )
        self.trust_proxy = os.getenv("TRUST_PROXY", "false").lower() == "true"
        self._requests: dict[str, list[float]] = defaultdict(list)
        self._lock = Lock()

    def check(self, request: Request) -> None:
        now = time.monotonic()
        key = self._client_key(request)
        limit = self.login_requests_per_minute if request.url.path == "/auth/login" else self.requests_per_minute

        with self._lock:
            timestamps = self._requests[key]
            timestamps[:] = [item for item in timestamps if now - item < 60]
            if len(timestamps) >= limit:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Too many requests. Please wait and try again.",
                )
            timestamps.append(now)

    def _client_key(self, request: Request) -> str:
        prefix = "login" if request.url.path == "/auth/login" else "general"
        if self.trust_proxy:
            forwarded = request.headers.get("X-Forwarded-For")
            if forwarded:
                return f"{prefix}:{forwarded.split(',')[0].strip()}"
        if request.client:
            return f"{prefix}:{request.client.host}"
        return f"{prefix}:unknown"


rate_limiter = RateLimiter()
