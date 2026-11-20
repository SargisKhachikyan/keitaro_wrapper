
import os
from pathlib import Path

import httpx
from dotenv import load_dotenv


ENV_FILE = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(ENV_FILE)


class KeitaroService:
    def __init__(self):
        self.base_url = os.getenv("KEITARO_BASE_URL")
        self.api_key = os.getenv("KEITARO_API_KEY")

        if not self.base_url or not self.api_key:
            raise ValueError("Keitaro settings are missing in .env")

        self.headers = {
            "Api-Key": self.api_key,
            "Accept": "application/json",
        }

    def _get(self, endpoint: str, params=None):
        response = httpx.get(
            f"{self.base_url.rstrip('/')}/admin_api/v1/{endpoint}",
            headers=self.headers,
            params=params,
            timeout=20,
        )
        response.raise_for_status()
        return response.json()

    def _post(self, endpoint: str, data: dict):
        response = httpx.post(
            f"{self.base_url.rstrip('/')}/admin_api/v1/{endpoint}",
            headers={
                **self.headers,
                "Content-Type": "application/json",
            },
            json=data,
            timeout=20,
        )
        response.raise_for_status()
        return response.json()

    def _put(self, endpoint: str, data: dict):
        response = httpx.put(
            f"{self.base_url.rstrip('/')}/admin_api/v1/{endpoint}",
            headers={
                **self.headers,
                "Content-Type": "application/json",
            },
            json=data,
            timeout=20,
        )
        response.raise_for_status()
        return response.json()

    def _delete(self, endpoint: str):
        response = httpx.delete(
            f"{self.base_url.rstrip('/')}/admin_api/v1/{endpoint}",
            headers=self.headers,
            timeout=20,
        )
        response.raise_for_status()

        if response.content:
            return response.json()

        return {"success": True}

    def get_campaigns(self):
        return self._get("campaigns")

    def get_groups(self):
        return self._get("groups", params={"type": "campaigns"})

    def get_domains(self):
        return self._get("domains")

    def get_traffic_sources(self):
        return self._get("traffic_sources")

    def get_offers(self):
        return self._get("offers")

    def get_stream_actions(self):
        return self._get("streams_actions")

    def get_stream_filters(self):
        return self._get("stream_filters")

    def get_campaign_streams(self, campaign_id: int):
        return self._get(f"campaigns/{campaign_id}/streams")

    def get_stream(self, stream_id: int):
        return self._get(f"streams/{stream_id}")

    def create_campaign(self, campaign_data: dict):
        return self._post("campaigns", campaign_data)

    def create_stream(self, stream_data: dict):
        return self._post("streams", stream_data)

    def update_stream(self, stream_id: int, stream_data: dict):
        return self._put(f"streams/{stream_id}", stream_data)

    def delete_stream(self, stream_id: int):
        return self._delete(f"streams/{stream_id}")
