import joblib
import pandas as pd
import os

_model = None

def load_model():
    global _model
    if _model is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(script_dir, "model.pkl")
        if os.path.exists(model_path):
            _model = joblib.load(model_path)
        else:
            raise FileNotFoundError("Model dosyası bulunamadı. Önce train_model.py çalıştırılmalı.")
    return _model

def evaluate_fatigue_score(overall_sleep_score: int, deep_sleep_mins: int, resting_hr: int, restlessness: float) -> float:
    """
    Fitbit'ten gelen günlük özet metrikleri alıp, kullanıcının o gün hissedeceği yorgunluk skorunu (1-5) tahmin eder.
    (Örn: 1 -> Çok Yorgun, 5 -> Çok Zinde (veya veri setindeki ölçeğe göre tam tersi))
    """
    model = load_model()
    
    input_df = pd.DataFrame([{
        'overall_score': overall_sleep_score,
        'deep_sleep_in_minutes': deep_sleep_mins,
        'resting_heart_rate': resting_hr,
        'restlessness': restlessness
    }])
    
    prediction = model.predict(input_df)[0]
    return round(prediction, 2)
    
if __name__ == "__main__":
    # Test
    # İyi Uyku (Skor: 85), Çok Derin Uyku (90dk), Düşük Nabız (55)
    print("Harika Bir Gece Testi (Tahmini Yorgunluk Skoru):", evaluate_fatigue_score(85, 90, 55, 0.05))
    
    # Kötü Uyku (Skor: 50), Az Derin Uyku (20dk), Yüksek Nabız (80)
    print("Berbat Bir Gece Testi (Tahmini Yorgunluk Skoru):", evaluate_fatigue_score(50, 20, 80, 0.20))
