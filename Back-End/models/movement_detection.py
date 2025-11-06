"""
Movement Detection Model
Pydantic models for movement_detections table
"""

from pydantic import BaseModel, Field, UUID4
from datetime import datetime
from typing import Optional, Literal


class MovementDetectionBase(BaseModel):
    """Base model for movement detection"""

    timestamp: int = Field(..., description="Timestamp in video (seconds)")
    name: str = Field(
        ..., description="Movement type name (e.g., 'tremor', 'dystonia')"
    )
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence score (0-1)")
    validation_status: Literal["pending", "confirmed", "rejected"] = Field(
        default="pending", description="Validation status by medical staff"
    )
    room_id: UUID4 = Field(..., description="UUID of the room")
    recording_id: UUID4 = Field(..., description="UUID of the recording")


class MovementDetectionCreate(MovementDetectionBase):
    """Model for creating a new movement detection"""

    pass


class MovementDetectionUpdate(BaseModel):
    """Model for updating movement detection"""

    timestamp: Optional[int] = None
    name: Optional[str] = None
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0)
    validation_status: Optional[Literal["pending", "confirmed", "rejected"]] = None
    room_id: Optional[UUID4] = None
    recording_id: Optional[UUID4] = None


class MovementDetectionResponse(MovementDetectionBase):
    """Model for movement detection response"""

    id: int = Field(..., description="Primary key")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "created_at": "2025-11-05T05:08:36.349524+00:00",
                "timestamp": 15.0,
                "name": "tremor",
                "confidence": 0.98,
                "validation_status": "pending",
                "room_id": "0f30f577-61a3-4a81-8c9f-64a952f718a1",
                "recording_id": "1bce4928-82fe-4252-99ce-789e2783d1bc",
                "updated_at": "2025-11-05T05:08:36.349524+00:00",
            }
        }


class MovementDetectionListResponse(BaseModel):
    """Model for paginated list of movement detections"""

    data: list[MovementDetectionResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


class ValidationStatusUpdate(BaseModel):
    """Model for updating validation status only"""

    validation_status: Literal["pending", "confirmed", "rejected"] = Field(
        ..., description="New validation status"
    )
