from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import datetime
import uvicorn
from ml.inference import evaluate_fatigue_score
from services.llm_service import generate_coach_advice
from services.db_service import save_daily_log

app = FastAPI(title="LifeWatch AI Coach API")

class HealthData(BaseModel):
    user_id: str
    overall_sleep_score: int
    deep_sleep_in_minutes: int
    resting_heart_rate: int
    restlessness: float
    timestamp: datetime.datetime

@app.get("/")
def read_root():
    return {"status": "ok", "message": "LifeWatch Backend is running!"}

@app.post("/api/health-data")
async def receive_health_data(data: HealthData, background_tasks: BackgroundTasks):
    """
    Mobil uygulamadan gelen günlük saat verilerini alır ve yapay zeka süreçlerini başlatır.
    """
    # Gerçek işlem (ML inference, Gemini API çağrısı, DB kaydı) arka planda yapılacak.
    background_tasks.add_task(process_health_data, data)
    return {"status": "received", "message": "Health data queued for AI processing."}

def process_health_data(data: HealthData):
    print(f"\n--- [AI İşlem Başladı] Kullanıcı: {data.user_id} ---")
    
    # 1. Makine Öğrenimi (Sol Lob) - Yorgunluk Skoru Tahmini
    fatigue_score = evaluate_fatigue_score(
        overall_sleep_score=data.overall_sleep_score,
        deep_sleep_mins=data.deep_sleep_in_minutes,
        resting_hr=data.resting_heart_rate,
        restlessness=data.restlessness
    )
    print(f"1. Makine Öğrenimi Skoru: {fatigue_score}/5 (Yorgunluk)")
    
    # 2. Gemini AI (Sağ Lob) - Koçluk Tavsiyesi Üretimi
    advice = generate_coach_advice(
        fatigue_score=fatigue_score,
        overall_sleep_score=data.overall_sleep_score,
        deep_sleep_mins=data.deep_sleep_in_minutes,
        resting_hr=data.resting_heart_rate
    )
    print(f"2. Yaşam Koçu Tavsiyesi:\n{advice}")
    
    # 3. Supabase - Veritabanına Kayıt
    raw_data = {
        "sleep_score": data.overall_sleep_score,
        "deep_sleep": data.deep_sleep_in_minutes,
        "hr": data.resting_heart_rate,
        "restlessness": data.restlessness
    }
    save_daily_log(data.user_id, fatigue_score, advice, raw_data)
    print("3. Veritabanı Kaydı: Başarılı")
    print("-------------------------------------------\n")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
