
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.models.campaign import Campaign
from app.schemas.campaign import CampaignCreate, CampaignResponse


router = APIRouter(prefix="/campaigns", tags=["Campaigns"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/", response_model=list[CampaignResponse])
def get_campaigns(db: Session = Depends(get_db)):
    return db.query(Campaign).all()


@router.post("/", response_model=CampaignResponse)
def create_campaign(
    campaign_data: CampaignCreate,
    db: Session = Depends(get_db),
):
    campaign = Campaign(
        name=campaign_data.name,
        geo=campaign_data.geo,
        offer_id=campaign_data.offer_id,
    )

    db.add(campaign)
    db.commit()
    db.refresh(campaign)

    return campaign


@router.put("/{campaign_id}", response_model=CampaignResponse)
def update_campaign(
    campaign_id: int,
    campaign_data: CampaignCreate,
    db: Session = Depends(get_db),
):
    campaign = db.query(Campaign).filter(
        Campaign.id == campaign_id
    ).first()

    if campaign is None:
        raise HTTPException(
            status_code=404,
            detail="Campaign not found",
        )

    campaign.name = campaign_data.name
    campaign.geo = campaign_data.geo
    campaign.offer_id = campaign_data.offer_id

    db.commit()
    db.refresh(campaign)

    return campaign


@router.delete("/{campaign_id}")
def delete_campaign(
    campaign_id: int,
    db: Session = Depends(get_db),
):
    campaign = db.query(Campaign).filter(
        Campaign.id == campaign_id
    ).first()

    if campaign is None:
        raise HTTPException(
            status_code=404,
            detail="Campaign not found",
        )

    db.delete(campaign)
    db.commit()

    return {"message": "Campaign deleted successfully"}
