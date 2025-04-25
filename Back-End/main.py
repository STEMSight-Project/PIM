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

app.include_router(api_router)