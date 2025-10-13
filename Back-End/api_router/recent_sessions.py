from fastapi import APIRouter, HTTPException, Depends
from typing import List
import csv
from io import StringIO
from fastapi.responses import StreamingResponse
from datetime import datetime
from core.common import get_supabase_client
from models.recent_session import RecentSession

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
