# Zlife - AI Powered Life Coach

Zlife, akıllı saatlerden gelen verileri (uyku, nabız) analiz ederek gerçek zamanlı klinik yorgunluk skoru (1-5) hesaplayan ve Groq (Llama-3.1) Yapay Zekası aracılığıyla kişiselleştirilmiş motivasyon mesajları üreten bir yaşam koçu arka uç (backend) sistemidir.

## Mimari
- **API Çatısı:** FastAPI
- **Makine Öğrenimi (Sol Lob):** Random Forest Regressor (Gözetimli Öğrenme)
- **Dil Modeli (Sağ Lob):** Groq Llama-3.1-8b-instant
- **Veritabanı:** Supabase

## Veri Seti Referansı (Dataset Citation)
Bu projenin Makine Öğrenimi modeli, açık kaynaklı **PMData** veri seti kullanılarak eğitilmiştir. Araştırma ekibine bilime yaptıkları bu açık kaynaklı katkıdan dolayı teşekkür ederiz. Veri seti doğrudan Kaggle üzerinden projeye entegre edilmiştir.

**Kaggle Linki:**
> [PMData - A sports logging dataset (Kaggle)](https://www.kaggle.com/datasets/vlbthambawita/pmdata-a-sports-logging-dataset)

**Akademik Referans (Citation):**
> Thambawita, V., Hicks, S.A., Borgli, H., et al. PMData: a sports logging dataset. *Sci Data 7*, 231 (2020). 
> [https://doi.org/10.1038/s41597-020-00573-0](https://doi.org/10.1038/s41597-020-00573-0)

## Güvenlik
Projenin çalışması için gereken API anahtarları (`GROQ_API_KEY`, `SUPABASE_KEY`) `.gitignore` kuralı gereği GitHub'a yüklenmez. Projeyi kendi bilgisayarınızda çalıştırmak için `backend/.env.example` dosyasını kopyalayarak `backend/.env` dosyası oluşturmalı ve içine kendi şifrelerinizi girmelisiniz.
