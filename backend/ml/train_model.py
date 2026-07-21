import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import os
import glob

def train_pmdata_model():
    base_path = r"C:\Users\burak\.cache\kagglehub\datasets\vlbthambawita\pmdata-a-sports-logging-dataset\versions\1\osfstorage-archive\pmdata"
    
    all_data = []
    
    # PMData'daki p01, p02... klasörlerini dönelim
    user_folders = glob.glob(os.path.join(base_path, "p*"))
    if not user_folders:
        print("HATA: PMData klasörleri bulunamadı. Kaggle indirmesi tamamlandı mı?")
        return
        
    print(f"{len(user_folders)} kullanıcı profili işleniyor...")
    
    for folder in user_folders:
        sleep_file = os.path.join(folder, "fitbit", "sleep_score.csv")
        wellness_file = os.path.join(folder, "pmsys", "wellness.csv")
        
        if os.path.exists(sleep_file) and os.path.exists(wellness_file):
            try:
                df_sleep = pd.read_csv(sleep_file)
                df_well = pd.read_csv(wellness_file)
                
                # Sütun adları boşluklu/farklı formatta olabilir, temizleyelim
                df_sleep.columns = df_sleep.columns.str.strip().str.lower()
                df_well.columns = df_well.columns.str.strip().str.lower()
                
                # Tarih eşleştirme
                # sleep_score -> 'timestamp', wellness -> 'effective_time_frame'
                if 'timestamp' in df_sleep.columns and 'effective_time_frame' in df_well.columns:
                    df_sleep['date'] = pd.to_datetime(df_sleep['timestamp']).dt.date
                    df_well['date'] = pd.to_datetime(df_well['effective_time_frame']).dt.date
                    
                    merged = pd.merge(df_sleep, df_well, on='date', how='inner')
                    all_data.append(merged)
            except Exception as e:
                print(f"Uyarı: {folder} okunamadı. Hata: {e}")
                
    if not all_data:
        print("HATA: Hiçbir ortak veri birleştirilemedi!")
        return
        
    df_final = pd.concat(all_data, ignore_index=True)
    
    # Kullanacağımız features: 
    # 'overall_score' (Fitbit Uyku Skoru), 'deep_sleep_in_minutes' (Derin Uyku), 
    # 'resting_heart_rate' (Dinlenik Nabız), 'restlessness' (Huzursuzluk)
    features = ['overall_score', 'deep_sleep_in_minutes', 'resting_heart_rate', 'restlessness']
    target = 'fatigue' # 1-5 arası anket skoru
    
    # Tüm kolonların df_final içinde olduğundan emin olalım
    missing_cols = [c for c in features + [target] if c not in df_final.columns]
    if missing_cols:
        print(f"HATA: Eksik kolonlar var: {missing_cols}")
        print("Mevcut kolonlar:", df_final.columns.tolist())
        return
        
    df_final = df_final[features + [target]].dropna()
    print(f"Başarıyla {len(df_final)} satırlık eğitim verisi oluşturuldu (Ground Truth Yorgunluk).")
    
    X = df_final[features]
    y = df_final[target]
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("Random Forest Regressor (Supervised) eğitiliyor...")
    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    
    print(f"Eğitim Tamamlandı! \nMean Squared Error (Hata payı): {mse:.2f}")
    
    print("\nÖrnek Tahminler (Gerçek vs Tahmin Edilen Yorgunluk Skoru 1-5):")
    results = pd.DataFrame({'Gerçek Yorgunluk': y_test.values, 'Tahmin Edilen': y_pred.round(1)})
    print(results.head(10))
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(script_dir, "model.pkl")
    joblib.dump(model, model_path)
    print(f"\nYeni Süper Zeka modeli başarıyla kaydedildi: {model_path}")

if __name__ == "__main__":
    train_pmdata_model()
