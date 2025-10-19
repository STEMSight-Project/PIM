from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class RecentSession(BaseModel):
    id: str
    patient_id: str
    patient_name: str
    timestamp: datetime
    duration: int  # duration in minutes
    total_detections: int
    total_alerts: int
    confidence_score: float
    camera_module: str
    status: str  # 'completed' or 'active'
    
    class Config:
        from_attributes = True