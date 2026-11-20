
import httpx
import logging
import re
import time
import unicodedata

from typing import Any, Dict, List, Literal, Optional

from fastapi import APIRouter, HTTPException, Path
from pydantic import BaseModel, Field

from app.services.keitaro_service import KeitaroService


router = APIRouter(prefix="/keitaro", tags=["Keitaro"])
logger = logging.getLogger("keitaro_wrapper")


class CreateCampaignRequest(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    domain_id: int = Field(gt=0)
    group_id: int = Field(gt=0)
    traffic_source_id: int = Field(gt=0)
    alias: Optional[str] = None


class StreamFilterRequest(BaseModel):
    name: str
    mode: Literal["accept", "reject"]
    payload: List[str]


class StreamOfferRequest(BaseModel):
    offer_id: int = Field(gt=0)
    share: int = Field(default=100, ge=0, le=100)
    state: Literal["active", "disabled"] = "active"


class ManageOffersRequest(BaseModel):
    offers: List[StreamOfferRequest]


class CreateStreamRequest(BaseModel):
    name: str
    type: Literal["forced", "regular", "default"] = "regular"
    schema: Literal["landings", "redirect", "action"]
    action_type: str
    action_options: Optional[Dict[str, Any]] = None
    filters: List[StreamFilterRequest] = Field(default_factory=list)
    offers: List[StreamOfferRequest] = Field(default_factory=list)


class UpdateStreamRequest(BaseModel):
    name: Optional[str] = None
    type: Optional[Literal["forced", "regular", "default"]] = None
    schema: Optional[Literal["landings", "redirect", "action"]] = None
    action_type: Optional[str] = None
    action_options: Optional[Dict[str, Any]] = None
    state: Optional[Literal["active", "disabled", "deleted"]] = None
    position: Optional[int] = None
    weight: Optional[float] = None
    comments: Optional[str] = None
    filters: Optional[List[StreamFilterRequest]] = None
    offers: Optional[List[StreamOfferRequest]] = None


def generate_alias(name: str) -> str:
    normalized = unicodedata.normalize("NFKD", name)
    normalized = normalized.encode("ascii", "ignore").decode("ascii")
    alias = re.sub(r"[^a-zA-Z0-9]+", "-", normalized.lower()).strip("-")

    if not alias:
        alias = f"campaign-{int(time.time())}"

    return alias


def handle_keitaro_error(error: httpx.HTTPStatusError):
    logger.warning(
        "Keitaro request rejected with upstream status %s",
        error.response.status_code,
    )
    raise HTTPException(
        status_code=error.response.status_code,
        detail={
            "message": "Keitaro rejected the request.",
            "keitaro_status": error.response.status_code,
        },
    )


def safe_response(data):
    if isinstance(data, dict):
        data.pop("token", None)
    return data


@router.get("/campaigns")
def get_keitaro_campaigns():
    try:
        campaigns = KeitaroService().get_campaigns()

        safe_campaigns = [
            {
                key: value
                for key, value in campaign.items()
                if key != "token"
            }
            for campaign in campaigns
        ]

        return {
            "success": True,
            "count": len(safe_campaigns),
            "campaigns": safe_campaigns,
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.get("/options")
def get_keitaro_options():
    try:
        service = KeitaroService()

        groups = service.get_groups()
        domains = service.get_domains()
        traffic_sources = service.get_traffic_sources()
        offers = service.get_offers()

        return {
            "success": True,
            "groups": [
                {"id": item["id"], "name": item["name"]}
                for item in groups
            ],
            "domains": [
                {
                    "id": item["id"],
                    "name": item["name"],
                    "state": item.get("state"),
                }
                for item in domains
            ],
            "traffic_sources": [
                {
                    "id": item["id"],
                    "name": item["name"],
                    "state": item.get("state"),
                }
                for item in traffic_sources
            ],
            "offers": [
                {
                    "id": item["id"],
                    "name": item["name"],
                    "group_id": item.get("group_id"),
                    "state": item.get("state"),
                }
                for item in offers
            ],
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.get("/stream-actions")
def get_stream_actions():
    try:
        return {
            "success": True,
            "actions": KeitaroService().get_stream_actions(),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.get("/stream-filters")
def get_stream_filters():
    try:
        return {
            "success": True,
            "filters": KeitaroService().get_stream_filters(),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.get("/campaigns/{campaign_id}/streams")
def get_campaign_streams(campaign_id: int = Path(..., gt=0)):
    try:
        streams = KeitaroService().get_campaign_streams(campaign_id)

        return {
            "success": True,
            "count": len(streams),
            "streams": streams,
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.get("/streams/{stream_id}")
def get_stream(stream_id: int = Path(..., gt=0)):
    try:
        stream = KeitaroService().get_stream(stream_id)

        return {
            "success": True,
            "stream": safe_response(stream),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.put("/streams/{stream_id}")
def update_stream(
    data: UpdateStreamRequest,
    stream_id: int = Path(..., gt=0),
):
    try:
        stream_data = data.model_dump(exclude_unset=True)

        stream = KeitaroService().update_stream(
            stream_id,
            stream_data,
        )

        return {
            "success": True,
            "message": "Stream updated successfully",
            "stream": safe_response(stream),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.put("/streams/{stream_id}/offers")
def manage_stream_offers(
    data: ManageOffersRequest,
    stream_id: int = Path(..., gt=0),
):
    try:
        service = KeitaroService()

        stream = service.update_stream(
            stream_id,
            {
                "offers": [
                    offer.model_dump()
                    for offer in data.offers
                ]
            },
        )

        return {
            "success": True,
            "message": "Stream offers updated successfully",
            "stream": safe_response(stream),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.delete("/streams/{stream_id}")
def delete_stream(stream_id: int = Path(..., gt=0)):
    try:
        result = KeitaroService().delete_stream(stream_id)

        return {
            "success": True,
            "message": "Stream deleted successfully",
            "result": safe_response(result),
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.post("/campaigns/{campaign_id}/streams")
def create_campaign_stream(
    data: CreateStreamRequest,
    campaign_id: int = Path(..., gt=0),
):
    try:
        service = KeitaroService()

        stream_data = data.model_dump(
            exclude={"filters"},
            exclude_none=True,
        )
        stream_data["campaign_id"] = campaign_id

        stream = service.create_stream(stream_data)

        filters = [
            item.model_dump()
            for item in data.filters
        ]

        if filters and isinstance(stream, dict) and stream.get("id"):
            stream = service.update_stream(
                stream["id"],
                {"filters": filters},
            )

        safe_response(stream)

        return {
            "success": True,
            "message": "Stream created successfully",
            "stream": stream,
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )


@router.post("/campaigns")
def create_keitaro_campaign(data: CreateCampaignRequest):
    try:
        alias = data.alias or generate_alias(data.name)

        campaign_data = {
            "name": data.name,
            "alias": alias,
            "domain_id": data.domain_id,
            "group_id": str(data.group_id),
            "traffic_source_id": data.traffic_source_id,
        }

        campaign = KeitaroService().create_campaign(campaign_data)

        safe_response(campaign)

        return {
            "success": True,
            "message": "Campaign created successfully",
            "campaign": campaign,
        }

    except httpx.HTTPStatusError as error:
        handle_keitaro_error(error)

    except Exception as error:
        raise HTTPException(
            status_code=502,
            detail=f"Internal error: {type(error).__name__}",
        )
