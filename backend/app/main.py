from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests

app = FastAPI()

class TranslationRequest(BaseModel):
    text: str
    target_language: str

# Replace these with your Microsoft Translator API details
MICROSOFT_TRANSLATOR_ENDPOINT = "https://api.cognitive.microsofttranslator.com/translate"
MICROSOFT_TRANSLATOR_KEY = "YOUR_API_KEY"
MICROSOFT_REGION = "YOUR_REGION"

@app.post("/translate/")
async def translate_text(request: TranslationRequest):
    headers = {
        "Ocp-Apim-Subscription-Key": MICROSOFT_TRANSLATOR_KEY,
        "Ocp-Apim-Subscription-Region": MICROSOFT_REGION,
        "Content-Type": "application/json"
    }
    body = [{"text": request.text}]
    params = {"to": request.target_language}

    response = requests.post(MICROSOFT_TRANSLATOR_ENDPOINT, headers=headers, params=params, json=body)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.text)
    translated_text = response.json()[0]["translations"][0]["text"]
    return {"translated_text": translated_text}
