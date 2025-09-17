from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
import whisper
from TTS.api import TTS
import osss

# Uygulama başlat
app = FastAPI()

# CORS ayarı (Flutter uygulamasından erişim için)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Gerekirse sadece belirli bir IP ile sınırla
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ASR ve TTS modellerini yükle
asr_model = whisper.load_model("base")
tts_model = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC", gpu=False)

# Ana endpoint
@app.get("/")
def home():
    return {"message": "VoiceNote API is running!"}

# Ses dosyasını yazıya çevir (Whisper)
@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    temp_path = "temp.wav"
    with open(temp_path, "wb") as f:
        f.write(await file.read())
    result = asr_model.transcribe(temp_path)
    os.remove(temp_path)
    return JSONResponse(content={"text": result["text"]})

# Yazıyı sese çevir (TTS)
@app.post("/speak")
async def speak(text: str = Form(...)):
    output_path = "tts_output.wav"
    tts_model.tts_to_file(text=text, file_path=output_path)
    return FileResponse(output_path, media_type="audio/wav", filename="note.wav")
