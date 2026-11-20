from unittest.mock import patch

import httpx
from fastapi.testclient import TestClient

from app.main import app
from app.core.security import backend_auth
from app.core.rate_limit import rate_limiter


client = TestClient(app)


@patch("app.api.routes.keitaro.KeitaroService")
def test_get_campaigns(mock_service):
    mock_service.return_value.get_campaigns.return_value = [
        {"id": 101, "name": "Test campaign", "alias": "test-campaign"}
    ]

    response = client.get("/keitaro/campaigns")

    assert response.status_code == 200
    assert response.json()["success"] is True
    assert response.json()["count"] == 1
    assert response.json()["campaigns"][0]["id"] == 101


@patch("app.api.routes.keitaro.KeitaroService")
def test_get_options(mock_service):
    service = mock_service.return_value
    service.get_groups.return_value = [{"id": 1, "name": "Group"}]
    service.get_domains.return_value = [{"id": 2, "name": "example.com", "state": "active"}]
    service.get_traffic_sources.return_value = [{"id": 3, "name": "Source", "state": "active"}]
    service.get_offers.return_value = [{"id": 4, "name": "Offer", "state": "active"}]

    response = client.get("/keitaro/options")

    assert response.status_code == 200
    assert response.json()["groups"] == [{"id": 1, "name": "Group"}]
    assert response.json()["domains"][0]["name"] == "example.com"


@patch("app.api.routes.keitaro.KeitaroService")
def test_get_campaign_streams(mock_service):
    mock_service.return_value.get_campaign_streams.return_value = [
        {
            "id": 200,
            "name": "Country",
            "offers": [],
            "filters": [{"name": "country", "mode": "accept", "payload": ["US"]}],
        }
    ]

    response = client.get("/keitaro/campaigns/101/streams")

    assert response.status_code == 200
    assert response.json()["count"] == 1
    assert response.json()["streams"][0]["id"] == 200


@patch("app.api.routes.keitaro.KeitaroService")
def test_manage_stream_offers(mock_service):
    mock_service.return_value.update_stream.return_value = {
        "id": 200,
        "offers": [{"offer_id": 4, "share": 100, "state": "active"}],
    }

    response = client.put(
        "/keitaro/streams/200/offers",
        json={"offers": [{"offer_id": 4, "share": 100, "state": "active"}]},
    )

    assert response.status_code == 200
    assert response.json()["success"] is True
    assert response.json()["stream"]["offers"][0]["offer_id"] == 4


def test_create_campaign_validation():
    response = client.post(
        "/keitaro/campaigns",
        json={
            "name": "",
            "domain_id": 2,
            "group_id": 1,
            "traffic_source_id": 3,
        },
    )

    assert response.status_code == 422


def test_create_stream_validation():
    response = client.post(
        "/keitaro/campaigns/101/streams",
        json={
            "name": "Country",
            "type": "regular",
            "schema": "invalid",
            "action_type": "http",
        },
    )

    assert response.status_code == 422


def test_cors_preflight():
    response = client.options(
        "/keitaro/campaigns",
        headers={
            "Origin": "http://127.0.0.1:8765",
            "Access-Control-Request-Method": "GET",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "http://127.0.0.1:8765"


def test_auth_status():
    response = client.get("/auth/status")

    assert response.status_code == 200
    assert "enabled" in response.json()


def test_share_validation_rejects_out_of_range():
    response = client.put(
        "/keitaro/streams/200/offers",
        json={"offers": [{"offer_id": 4, "share": 101, "state": "active"}]},
    )

    assert response.status_code == 422


def test_invalid_campaign_id_is_rejected():
    response = client.get("/keitaro/campaigns/0/streams")

    assert response.status_code == 422


def test_auth_login_success_and_protected_request(monkeypatch):
    monkeypatch.setattr(backend_auth, "enabled", True)
    monkeypatch.setattr(backend_auth, "username", "qa-user")
    monkeypatch.setattr(backend_auth, "password", "qa-password")

    login = client.post(
        "/auth/login",
        json={"username": "qa-user", "password": "qa-password"},
    )
    assert login.status_code == 200
    token = login.json()["access_token"]

    response = client.get(
        "/keitaro/options",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code in (200, 502)


def test_auth_rejects_missing_token(monkeypatch):
    monkeypatch.setattr(backend_auth, "enabled", True)

    response = client.get("/keitaro/options")

    assert response.status_code == 401


def test_rate_limit_returns_429(monkeypatch):
    monkeypatch.setattr(rate_limiter, "requests_per_minute", 1)
    rate_limiter._requests.clear()

    first = client.get("/health")
    second = client.get("/health")

    assert first.status_code == 200
    assert second.status_code == 429


@patch("app.api.routes.keitaro.KeitaroService")
def test_keitaro_error_does_not_return_upstream_body(mock_service):
    mock_service.return_value.get_campaigns.side_effect = httpx.HTTPStatusError(
        "upstream",
        request=httpx.Request("GET", "https://keitaro.test/admin_api/v1/campaigns"),
        response=httpx.Response(
            401,
            request=httpx.Request("GET", "https://keitaro.test/admin_api/v1/campaigns"),
            text="secret upstream response",
        ),
    )

    response = client.get("/keitaro/campaigns")

    assert response.status_code == 401
    assert "secret upstream response" not in response.text
