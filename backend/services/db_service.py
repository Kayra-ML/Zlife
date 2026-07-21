from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if SUPABASE_URL and SUPABASE_KEY and SUPABASE_URL != "your_supabase_url_here":
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
else:
    supabase = None

def save_daily_log(user_id: str, fatigue_score: float, advice: str, raw_data: dict) -> bool:
    """
    Kullanıcının o günkü sağlık verisini, yapay zeka skorunu ve Gemini tavsiyesini veritabanına kaydeder.
    """
    if not supabase:
        print(f"[MOCK] Supabase'e kaydedildi simülasyonu -> User: {user_id} | Score: {fatigue_score}")
        return True
        
    try:
        data, count = supabase.table("daily_logs").insert({
            "user_id": user_id,
            "fatigue_score": fatigue_score,
            "ai_advice": advice,
            "raw_metrics": raw_data
        }).execute()
        
        return True
    except Exception as e:
        print(f"Supabase Kayıt Hatası: {e}")
        return False
