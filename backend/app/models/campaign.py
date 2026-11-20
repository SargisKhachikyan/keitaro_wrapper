from sqlalchemy import Column, Integer, String
from app.core.database import Base


class Campaign(Base):
    __tablename__ = "campaigns"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    geo = Column(String, nullable=False)
    offer_id = Column(Integer, nullable=False)