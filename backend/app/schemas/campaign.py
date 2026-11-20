import re

from pydantic import BaseModel, ConfigDict, Field, field_validator


class CampaignCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    geo: str = Field(min_length=2, max_length=2)
    offer_id: int = Field(gt=0)

    @field_validator("geo")
    @classmethod
    def validate_geo(cls, value: str) -> str:
        if re.fullmatch(r"[A-Za-z]{2}", value) is None:
            raise ValueError("GEO must be a two-letter country code")
        return value.upper()


class CampaignResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    geo: str
    offer_id: int