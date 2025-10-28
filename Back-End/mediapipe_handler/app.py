from fastapi import FastAPI, Request
from fastapi.responses import PlainTextResponse
from fastapi.staticfiles import StaticFiles
from webrtc_server import process_offer

app = FastAPI()

# Serve static browser test client
app.mount("/", StaticFiles(directory="static", html=True), name="static")


@app.post("/offer", response_class=PlainTextResponse)
async def offer(request: Request):
    sdp_offer = await request.body()
    response_sdp = await process_offer(sdp_offer.decode("utf-8"))
    return PlainTextResponse(response_sdp)


@app.get("/health")
async def health_check():
    return {"status": "running"}
