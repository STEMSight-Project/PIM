from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.exceptions import RequestValidationError
from api_router.router import api_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title= "STEMSight API", 
    version="1.0.0"
)

origins = [
    "http://127.0.0.1:3000",   # React / Next dev server
    "http://localhost:3000",   # add both forms so you can't miss
    "https://main.d3nf33ntk31bcv.amplifyapp.com",
    # "https://app.example.com",   # your production URL goes here
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
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