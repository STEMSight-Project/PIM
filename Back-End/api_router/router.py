from fastapi import APIRouter
from api_router.patient import router as patient_router
from api_router.auth import router as auth_router
from api_router.doctor import router as doctor_router
from api_router.medical_history import router as medical_history_router
from api_router.video import router as video_router
from api_router.video_streaming_ws import router as video_streaming_router

api_router = APIRouter()

"""Guys!! All router should be here!!"""
api_router.include_router(patient_router, prefix="/patients", tags = ["Patients"])
api_router.include_router(auth_router, prefix="/auth", tags = ["Auth"])
api_router.include_router(medical_history_router, prefix= "/medical-history", tags = ["Medical History"])
api_router.include_router(doctor_router, prefix="/doctors", tags = ["Doctors"])
api_router.include_router(video_router, prefix='/videos', tags = ["Videos"])
api_router.include_router(video_streaming_router, prefix='/video-streaming', tags = ["Video Streaming"])