from tempfile import template
from fastapi import FastAPI, Query, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.exceptions import RequestValidationError
from api_router.router import api_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title= "STEMSight API", version="1.0.0")
templates = Jinja2Templates(directory="templates")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with actual frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return {"error": "Invalid request", "details": exc.errors()}

@app.get("/")
def read_root():
    return RedirectResponse(url= '/docs')

@app.get("/live-broadcast", response_class=HTMLResponse)
async def live_broadcast(request: Request, patient_id: str = Query("test_patient", description="Patient ID for broadcast")):
    return templates.TemplateResponse("receiver.html", {"request": request, "patient_id": patient_id})


app.include_router(api_router)