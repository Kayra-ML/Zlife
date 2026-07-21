import os
from dotenv import load_dotenv
from groq import Groq

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")

if GROQ_API_KEY and GROQ_API_KEY != "your_groq_api_key_here":
    client = Groq(api_key=GROQ_API_KEY)
else:
    client = None

def generate_coach_advice(fatigue_score: float, overall_sleep_score: int, deep_sleep_mins: int, resting_hr: int) -> str:
    """
    Yapay zeka yorgunluk skorunu ve uyku verilerini alarak, kullanıcıya samimi, motive edici bir yaşam koçu tavsiyesi üretir.
    """
    if not client:
        return f"[MOCK] Harika bir gün! AI Yorgunluk Skorunuz: {fatigue_score}. Lütfen GROQ_API_KEY girin."
        
    prompt = f"""
    Sen, kullanıcının akıllı saat verilerini inceleyen şefkatli, bilimsel ve motive edici bir gerçek zamanlı Yapay Zeka Yaşam Koçusun.
    Kullanıcının bugünkü verileri:
    - AI Tahmini Yorgunluk Skoru (1-5 arası, düşükse çok yorgun, yüksekse zinde): {fatigue_score}
    - Geceki Toplam Uyku Skoru (0-100): {overall_sleep_score}
    - Derin Uyku Süresi: {deep_sleep_mins} dakika
    - Dinlenik Nabız: {resting_hr} bpm

    Bu verilere bakarak, bugünü nasıl geçirmesi gerektiğine dair Türkçe, maksimum 3 cümlelik, enerjik ve arkadaşça bir tavsiye yaz. 
    Eğer yorgunluk skoru 3'ün altındaysa (yani vücudu yorgunsa) daha sakin bir gün geçirmesini ve ağır antrenman yapmamasını ön plana çıkar.
    """
    
    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": "Sen profesyonel, motive edici ve Türkçe konuşan bir kişisel yaşam koçusun."
                },
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="llama-3.1-8b-instant",
        )
        return chat_completion.choices[0].message.content.strip()
    except Exception as e:
        return f"Groq API Hatası: {str(e)}"
