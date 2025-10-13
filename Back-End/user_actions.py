from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime
from core.common import supabase, logger
from security.jwt_verify import router_auth_dependency, CurrentUser
from pydantic import BaseModel

router = APIRouter(dependencies=[Depends(router_auth_dependency)])


class PatientAuditLog(BaseModel):
    id: str
    user_id: str
    patient_id: str
    action_type: str
    timestamp: datetime
    metadata: Optional[dict] = None


def is_admin(user: dict) -> bool:
    """Check if user is admin based"""
    return user.get("user_metadata", {}).get("role") == "admin"


def admin_dependency(user: CurrentUser) -> dict:
    """Require admin role."""
    if not is_admin(user):
        raise HTTPException(status_code=403, detail="Admin access required")
    return user


async def log_patient_action(user_id: str, patient_id: str, action_type: str, metadata: Optional[dict] = None) -> bool:
    """Log a patient-related action to the audit table.

    Returns True on successful write, False otherwise. Errors are logged.
    """
    try:
        log_data = {
            "user_id": user_id,
            "patient_id": patient_id,
            "action_type": action_type,
            "timestamp": datetime.utcnow().isoformat(),
            "metadata": metadata or {},
        }
        result = supabase.table("patient_audit_logs").insert(log_data).execute()
        if not result or result.data is None:
            logger.error(
                "Failed to insert audit log for user %s, patient %s, action %s", user_id, patient_id, action_type
            )
            return False
        return True
    except Exception as e:
        logger.exception("Error logging patient action: %s", e)
        return False


@router.get("/audit-logs", response_model=List[PatientAuditLog])
async def get_audit_logs(
    user_id: Optional[str] = Query(None),
    patient_id: Optional[str] = Query(None),
    action_type: Optional[str] = Query(None),
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    user: dict = Depends(router_auth_dependency),
):
    # Enforce admin access
    if not is_admin(user):
        raise HTTPException(status_code=403, detail="Admin access required")

    try:
        query = supabase.table("patient_audit_logs").select("*")

        if user_id:
            query = query.eq("user_id", user_id)
        if patient_id:
            query = query.eq("patient_id", patient_id)
        if action_type:
            query = query.eq("action_type", action_type)
        if start_date:
            query = query.gte("timestamp", start_date.isoformat())
        if end_date:
            query = query.lte("timestamp", end_date.isoformat())

        result = query.order("timestamp", desc=True).execute()

        if result.data is None:
            return []

        for log in result.data:
            if isinstance(log.get("timestamp"), datetime):
                log["timestamp"] = log["timestamp"].isoformat()

        return result.data
    except Exception as e:
        logger.exception("Failed to retrieve audit logs: %s", e)
        raise HTTPException(status_code=500, detail="Failed to retrieve audit logs")
