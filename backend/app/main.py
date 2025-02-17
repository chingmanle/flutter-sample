from fastapi import FastAPI, HTTPException
import httpx
import os
from dotenv import load_dotenv

# Load API key from .env file
load_dotenv()
LIBRE_TRANSLATE_API_KEY = "my-secret-api-keyss"

LIBRE_TRANSLATE_URL = "http://libretranslate:5000"

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Translation API is running!"}

@app.post("/translate/")
async def translate_text(text: str, target: str, source: str = "auto"):
    if not LIBRE_TRANSLATE_API_KEY:
        raise HTTPException(status_code=500, detail="API Key not configured")

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{LIBRE_TRANSLATE_URL}/translate",
            json={
                "q": text,
                "source": source,
                "target": target,
                "format": "text",
                "api_key": LIBRE_TRANSLATE_API_KEY  # Secure API key
            }
        )

    if response.status_code == 200:
        return response.json()
    else:
        raise HTTPException(status_code=response.status_code, detail="Translation failed")
