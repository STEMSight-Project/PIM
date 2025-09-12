from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
from api_router.router import api_router

app = FastAPI(
    title="STEMSight API", 
    version="1.0.0",
    description="STEMSight API with Bearer Token Authentication",
    openapi_tags=[
        {"name": "Auth", "description": "Authentication endpoints"},
        {"name": "Patients", "description": "Patient management"},
        {"name": "Doctors", "description": "Doctor management"},
        {"name": "Videos", "description": "Video management"},
        {"name": "Medical History", "description": "Medical history management"},
        {"name": "Notes", "description": "Notes management"},
        {"name": "Patient Events", "description": "Patient events management"},
        {"name": "Streaming", "description": "Real-time streaming"},
    ]
)

# Configure OpenAPI with Bearer token support
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="STEMSight API",
        version="1.0.0",
        description="STEMSight API with Bearer Token Authentication",
        routes=app.routes,
    )
    
    # Add Bearer token security scheme (but don't require it on all endpoints)
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter your JWT token (get it from /auth/login endpoint)"
        }
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

# CORS configuration
origins = [
    "http://127.0.0.1:8000",
    "http://127.0.0.1:3000",
    "http://localhost:3000",
    "https://localhost:3000",
    "https://main.d3nf33ntk31bcv.amplifyapp.com"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=False,  # Changed to False since we're using Bearer tokens, not cookies
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler((RequestValidationError))
async def validation_exception_handler(request, exc):
    return {"error": "Invalid request", "details": exc.errors()}

@app.get("/")
def read_root():
    """Redirect to API documentation"""
    return RedirectResponse(url='/docs')

app.include_router(api_router)