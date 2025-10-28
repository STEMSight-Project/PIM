"""
FastAPI Router for PIM Movement Classifier
Uses PIMClassifierService for business logic
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict
import numpy as np
import sys
from pathlib import Path

# Import the service layer
sys.path.insert(0, str(Path(__file__).parent.parent))
from services.ai.pim_classifier_service import (
    get_classifier_service,
    MovementPrediction,
)

# ============================================================
# API Router Setup
# ============================================================

router = APIRouter(prefix="/api/pim", tags=["PIM Classification"])


# Get singleton service instance (loads model on first call)
def get_service():
    """Dependency to get classifier service"""
    return get_classifier_service()


# ============================================================
# Request/Response Models
# ============================================================


class SkeletonFrame(BaseModel):
    """Single frame of skeleton data (33 joints × 3 coordinates)"""

    landmarks: List[List[float]]  # [[x, y, vis], [x, y, vis], ...]


class SkeletonSequence(BaseModel):
    """Sequence of skeleton frames for classification"""

    frames: List[SkeletonFrame]
    patient_id: Optional[str] = None
    recording_id: Optional[str] = None


class PredictionResponse(BaseModel):
    """Movement classification result"""

    predicted_movement: str
    confidence: float
    all_probabilities: Dict[str, float]
    patient_id: Optional[str] = None
    recording_id: Optional[str] = None
    tier: str  # "excellent", "good", "needs_review"
    recommendation: str


class BatchPredictionRequest(BaseModel):
    """Multiple skeleton sequences for batch processing"""

    sequences: List[SkeletonSequence]


# ============================================================
# Helper Functions
# ============================================================


def convert_to_response(
    prediction: MovementPrediction,
    patient_id: Optional[str] = None,
    recording_id: Optional[str] = None,
) -> PredictionResponse:
    """Convert service prediction to API response"""
    return PredictionResponse(
        predicted_movement=prediction.predicted_class,
        confidence=prediction.confidence,
        all_probabilities=prediction.all_probabilities,
        patient_id=patient_id,
        recording_id=recording_id,
        tier=prediction.tier,
        recommendation=prediction.recommendation,
    )


# ============================================================
# API Endpoints
# ============================================================


@router.post("/classify-movement", response_model=PredictionResponse)
async def classify_movement(sequence: SkeletonSequence):
    """
    Classify a single skeleton sequence into one of 9 PIM movement types

    **Movement Classes:**
    - Ballistic (95.3% accuracy)
    - Chorea (92.2% accuracy)
    - Decerebrate (45.2% accuracy - needs review)
    - Decorticate (100% accuracy)
    - Dystonia (98.4% accuracy)
    - Fencer Posture (98.4% accuracy)
    - Myoclonus (37.5% accuracy - needs review)
    - Tremor (100% accuracy)
    - Versive Head (93.6% accuracy)

    **Returns:**
    - Predicted movement type
    - Confidence score
    - All class probabilities
    - Tier rating and recommendation
    """
    try:
        # Get service
        service = get_service()

        # Convert frames to numpy array
        skeleton_data = np.array(
            [frame.landmarks for frame in sequence.frames]
        )  # Shape: (frames, 33, 3)

        # Prepare metadata
        metadata = {
            "patient_id": sequence.patient_id,
            "recording_id": sequence.recording_id,
        }

        # Make prediction using service
        prediction = service.predict(skeleton_data, metadata)

        # Convert to response
        return convert_to_response(
            prediction,
            patient_id=sequence.patient_id,
            recording_id=sequence.recording_id,
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@router.post("/classify-batch")
async def classify_batch(request: BatchPredictionRequest):
    """
    Classify multiple skeleton sequences in batch
    Useful for processing recorded sessions
    """
    try:
        # Get service
        service = get_service()

        # Prepare data
        skeleton_data_list = []
        metadata_list = []

        for sequence in request.sequences:
            # Convert to numpy
            skeleton_data = np.array([frame.landmarks for frame in sequence.frames])
            skeleton_data_list.append(skeleton_data)

            # Metadata
            metadata_list.append(
                {
                    "patient_id": sequence.patient_id,
                    "recording_id": sequence.recording_id,
                }
            )

        # Batch predict using service
        predictions = service.predict_batch(skeleton_data_list, metadata_list)

        # Convert to response format
        results = []
        for prediction, metadata in zip(predictions, metadata_list):
            results.append(
                {
                    "predicted_movement": prediction.predicted_class,
                    "confidence": prediction.confidence,
                    "all_probabilities": prediction.all_probabilities,
                    "patient_id": metadata.get("patient_id"),
                    "recording_id": metadata.get("recording_id"),
                    "tier": prediction.tier,
                    "recommendation": prediction.recommendation,
                }
            )

        return {
            "total_sequences": len(request.sequences),
            "successful_predictions": len(results),
            "predictions": results,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch prediction error: {str(e)}")


@router.get("/model-info")
async def get_model_info():
    """Get information about the loaded model"""
    try:
        service = get_service()
        return service.get_model_info()
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error getting model info: {str(e)}"
        )


@router.get("/health")
async def health_check():
    """Check if the model is loaded and ready"""
    try:
        service = get_service()
        return service.get_health_status()
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}


# ============================================================
# Usage Example in main.py
# ============================================================

"""
TO USE THIS IN YOUR BACK-END:

1. Add to your main.py:

from api_router.pim_classifier_api import router as pim_router

app = FastAPI()
app.include_router(pim_router)


2. Test the API:

curl -X POST http://localhost:8000/api/pim/classify-movement \\
  -H "Content-Type: application/json" \\
  -d '{
    "frames": [
      {
        "landmarks": [[0.5, 0.5, 0.9], [0.6, 0.6, 0.9], ...]  # 33 joints
      },
      ... # 60 frames
    ],
    "patient_id": "P001",
    "recording_id": "R001"
  }'


3. Response:

{
  "predicted_movement": "tremor",
  "confidence": 0.95,
  "all_probabilities": {
    "tremor": 0.95,
    "myoclonus": 0.03,
    ...
  },
  "tier": "excellent",
  "recommendation": "High confidence prediction - clinically ready"
}
"""
