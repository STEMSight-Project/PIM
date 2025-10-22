from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
import csv
from io import StringIO
from fastapi.responses import StreamingResponse
from datetime import datetime
from core.common import get_supabase_client
from models.recent_session import RecentSession
from pydantic import BaseModel

# Frontend TypeScript interface for this model:
"""
interface Prediction {
    timestamp: number;        // Video timestamp in seconds
    prediction: string;       // Type of prediction
    confidence: number;       // Confidence score (0-1)
    video_id: string;        // Reference to video session
    timestamp_formatted?: string; // MM:SS format for display
}
"""
class PredictionData(BaseModel):
    timestamp: float         # Video timestamp in seconds
    prediction: str         # Type of prediction
    confidence: float       # Confidence score (0-1)
    video_id: str          # Reference to video session

router = APIRouter()

@router.get("/recent-sessions")
async def get_recent_sessions():
    """Get all recent live monitoring sessions."""
    try:
        supabase = get_supabase_client()
        response = supabase.table('monitoring_sessions').select('*').execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/recent-sessions/{session_id}")
async def get_session_details(session_id: str):
    """Get detailed information about a specific session."""
    try:
        supabase = get_supabase_client()
        # Get session data with patient information
        response = supabase.table('monitoring_sessions')\
            .select('*, patients!inner(*)')\
            .eq('id', session_id)\
            .single()\
            .execute()
            
        if not response.data:
            raise HTTPException(status_code=404, detail="Session not found")
            
        session_data = response.data
        
        # Calculate additional metrics
        duration_mins = session_data.get('duration', 0)
        total_detections = session_data.get('total_detections', 0)
        alerts = session_data.get('total_alerts', 0)
        
        detection_rate = total_detections / duration_mins if duration_mins > 0 else 0
        alert_rate = alerts / duration_mins if duration_mins > 0 else 0
        
        # Enhance the response with detailed metrics
        detailed_response = {
            **session_data,
            'metrics': {
                'detection_rate_per_minute': round(detection_rate, 2),
                'alert_rate_per_minute': round(alert_rate, 2),
                'session_duration_formatted': f"{duration_mins} minutes",
                'confidence_score_formatted': f"{session_data.get('confidence_score', 0):.1f}%"
            },
            'timestamp_formatted': datetime.fromisoformat(session_data['timestamp']).strftime("%B %d, %Y %I:%M %p")
        }
        
        return detailed_response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/patient/{patient_id}")
async def get_patient_details(patient_id: str):
    """Get patient information by ID."""
    try:
        supabase = get_supabase_client()
        response = supabase.table('patients').select('*').eq('id', patient_id).single().execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Patient not found")
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/export-report")
async def export_sessions_report():
    """Export recent sessions data as CSV with detailed metrics."""
    try:
        supabase = get_supabase_client()
        # Get sessions with patient information
        sessions = supabase.table('monitoring_sessions')\
            .select('*, patients!inner(name, id, medical_record_number)')\
            .execute()
        
        # Create CSV string
        output = StringIO()
        writer = csv.writer(output)
        
        # Write headers
        headers = [
            'Session ID',
            'Patient Name',
            'Patient ID',
            'Medical Record Number',
            'Session Date',
            'Session Time',
            'Duration (minutes)',
            'Total Detections',
            'Detections/Minute',
            'Total Alerts',
            'Alerts/Minute',
            'Confidence Score',
            'Camera Module',
            'Session Status'
        ]
        writer.writerow(headers)
        
        # Write data rows
        for session in sessions.data:
            # Calculate metrics
            duration = session.get('duration', 0)
            detections = session.get('total_detections', 0)
            alerts = session.get('total_alerts', 0)
            
            detection_rate = round(detections / duration if duration > 0 else 0, 2)
            alert_rate = round(alerts / duration if duration > 0 else 0, 2)
            
            # Format timestamp
            timestamp = datetime.fromisoformat(session.get('timestamp'))
            date_str = timestamp.strftime("%Y-%m-%d")
            time_str = timestamp.strftime("%I:%M %p")
            
            # Get patient info
            patient = session.get('patients', {})
            
            writer.writerow([
                session.get('id'),
                patient.get('name', 'N/A'),
                patient.get('id', 'N/A'),
                patient.get('medical_record_number', 'N/A'),
                date_str,
                time_str,
                duration,
                detections,
                detection_rate,
                alerts,
                alert_rate,
                f"{session.get('confidence_score', 0):.1f}%",
                session.get('camera_module', 'N/A'),
                session.get('status', 'Completed')
            ])
        
        # Create response with CSV file
        response = StreamingResponse(
            iter([output.getvalue()]),
            media_type="text/csv",
            headers={
                "Content-Disposition": f"attachment; filename=monitoring_sessions_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            }
        )
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/video/{video_id}/predictions")
async def get_video_predictions(video_id: str):
    """Get all predictions for a specific video session.
    
    Frontend Implementation Guide:
    1. Call this endpoint when loading a video playback session
    2. Store the predictions array in state, indexed by timestamp
    3. UI Components needed:
       - Prediction timeline below video player
       - Prediction markers at specific timestamps
       - Tooltip or sidebar showing prediction details
    ```
    """
    try:
        supabase = get_supabase_client()
        response = supabase.table('session_predictions')\
            .select('*')\
            .eq('video_id', video_id)\
            .order('timestamp')\
            .execute()
        
        if not response.data:
            return []
            
        # Format predictions with timestamps for frontend display
        predictions = []
        for pred in response.data:
            predictions.append({
                'timestamp': pred['timestamp'],
                'prediction': pred['prediction'],
                'confidence': pred['confidence'],
                'timestamp_formatted': datetime.fromtimestamp(pred['timestamp']).strftime('%M:%S')
            })
            
        return predictions
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/video/{video_id}/predictions")
async def add_video_prediction(video_id: str, prediction_data: PredictionData):
    """Add a new prediction for a video session.
    
    Frontend Implementation Guide:
    1. Create a PredictionTimeline component to visualize predictions
    2. Add click handlers on timeline to jump to prediction timestamps
    3. Style predictions based on confidence scores
    
    ```
    
    """
    try:
        supabase = get_supabase_client()
        
        # Insert prediction data
        prediction = {
            'video_id': video_id,
            'timestamp': prediction_data.timestamp,
            'prediction': prediction_data.prediction,
            'confidence': prediction_data.confidence
        }
        
        response = supabase.table('session_predictions').insert(prediction).execute()
        
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/video/{video_id}/predictions/summary")
async def get_predictions_summary(video_id: str):
    """Get a summary of predictions for a video session.
    
    Frontend Implementation Guide:
    1. Use this endpoint to show session overview statistics
    2. Create visualization components for the summary data
    
    
    
    2. Visualization Components:
    - Bar chart showing prediction type distribution
    - Confidence score gauge
    - Timeline heatmap of prediction density
    - Export functionality for detailed analysis
    """
    try:
        supabase = get_supabase_client()
        predictions = supabase.table('session_predictions')\
            .select('prediction, confidence')\
            .eq('video_id', video_id)\
            .execute()
            
        if not predictions.data:
            return {
                'total_predictions': 0,
                'prediction_types': {},
                'average_confidence': 0
            }
            
        # Calculate summary statistics
        prediction_counts = {}
        total_confidence = 0
        
        for pred in predictions.data:
            pred_type = pred['prediction']
            prediction_counts[pred_type] = prediction_counts.get(pred_type, 0) + 1
            total_confidence += pred['confidence']
            
        summary = {
            'total_predictions': len(predictions.data),
            'prediction_types': prediction_counts,
            'average_confidence': round(total_confidence / len(predictions.data), 2)
        }
        
        return summary
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
