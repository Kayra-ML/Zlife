# Zlife: AI-Powered Life Coach & Clinical Fatigue Predictor

![Zcore Banner](banner.png)

Zlife, akıllı saatlerden (Apple Watch vb.) alınan sağlık verilerini **Apple HealthKit** üzerinden çekerek, makine öğrenimi tabanlı **Klinik Yorgunluk Skoru** hesaplayan gelişmiş bir yapay zeka mimarisidir.

Proje iki ana bileşenden oluşur:
1. **Zlife Backend (Makine Öğrenimi):** PMData veri seti ile eğitilmiş Random Forest modeli.
2. **Zlife iOS App (Flutter):** Apple HealthKit ile yerleşik senkronizasyon sağlayan, şık tasarımlı mobil arayüz.

---

## 🧠 Sol Lob: Makine Öğrenimi (Model & Zeka)

Zlife'ın kalbinde, klinik düzeyde hesaplamalar yapan gelişmiş bir Makine Öğrenimi modeli yatar. Bu model rastgele yazılmış `if/else` bloklarından değil, gerçek bilimsel verilerden beslenir.

### Veri Seti (PMData)
Bu projenin modeli, açık kaynaklı **PMData** (A sports logging dataset) veri seti kullanılarak eğitilmiştir. Sporculardan aylarca toplanan akıllı saat, uyku ve kalori verilerinden elde edilen desenler modelimize öğretilmiştir.

> Thambawita, V., et al. "PMData: a sports logging dataset." *Proceedings of the 11th ACM Multimedia Systems Conference*. 2020. [https://doi.org/10.1145/3339825.3394926](https://doi.org/10.1145/3339825.3394926)

### Model Özellikleri (Random Forest)
- **Girdiler (Features):** Uyku Skoru (1-100), Derin Uyku Süresi (Dakika), Dinlenik Nabız (BPM), Uyku İçi Hareketlilik (Restlessness).
- **Algoritma:** Algoritma olarak karmaşık ve kararlı ağaç yapılarından oluşan **Random Forest Regressor** kullanılmıştır. Karar ağaçlarının çoklu oylaması sayesinde aşırı öğrenme (overfitting) engellenmiştir.
- **Performans:** Modelimizin Test MSE (Ortalama Karesel Hata) değeri **0.51**'dir. Bu da 1-5 arasındaki bir yorgunluk skorunda sadece 0.5 ile 0.7 puanlık ufak bir sapma payıyla **gerçeğe en yakın klinik sonucu** verdiği anlamına gelir.

---

## 🧠 Kullanıcıya Özel Adaptasyon (Kendi Normalini Çözme)

Modelin en eşsiz özelliği sadece sabit bir skor vermek yerine, kullanıcının zaman içindeki verilerini analiz ederek ekrandaki **Analiz Barını (Progress Ring)** doldurmasıdır.
Model, cihazdan sürekli akan verileri okudukça belli bir süre sonra **kullanıcının kendi biyolojik normalini (Baseline)** çözer. Başkası için "yorgunluk" sayılabilecek bir nabız, sizin için "normal" ise model buna adapte olur ve Analiz Barı tamamen size özel kalibre edilmiş bir klinik tablo çizer.

---

# 📱 Zlife Mobil Uygulama (iOS & Flutter)

Mobil arayüzümüz, Apple ekosistemine tam uyumlu çalışacak şekilde **Flutter** ve **Swift** karışımı hibrit bir mimariyle geliştirilmiştir.

### Apple HealthKit Köprüsü (Sıfır Batarya Kaybı)
Uygulamanın en büyük mühendislik başarısı şudur: **Saat, Bluetooth ile uygulamaya direkt bağlanmaya çalışmaz!** 
Akıllı saatler kendi doğasında zaten Apple'ın "Sağlık (Health)" uygulamasını sürekli günceller. Zlife iOS uygulaması, arka planda çalışan `WatchDataService` üzerinden bu HealthKit verilerini (kullanıcı izinleriyle) güvenli bir şekilde okur. 
*   **Faydası:** Kopan Bluetooth bağlantılarıyla uğraşılmaz, uygulamanın şarjı sömürmesi engellenir ve veri akışı %100 kararlı çalışır.

### Gelişmiş Flutter Mimarisi
- **State Management:** Veri akışı `Provider` paketi kullanılarak merkezi ve anlık olarak yönetilir. (Sensörlerden gelen veriler anında arayüze yansır).
- **API (Backend) Entegrasyonu:** `MLApiService` servisi aracılığıyla, Apple Health'ten çekilen ham veriler paketlenip Python (FastAPI) sunucumuza gönderilir ve geriye kullanıcıya özel "Hesaplanmış Yorgunluk Skoru" döner. Bu skor ekrandaki Bar/Halka tasarımını doldurur.

---

## 🛠️ Geliştirme Yaklaşımı ve Mimari Notlar

Bu proje, bir "Flutter Eğitim veya Şablon Projesi" değildir.

Mobil arayüzümüz (iOS & Flutter), Zlife yapay zeka modelinin ürettiği karmaşık sağlık skorlarını ekrana yansıtmak için bir "araç" olarak tasarlanmıştır. Arayüzün kodlanması ve UI/UX mimarisinin oluşturulması sırasında **Modern IDE Araçları ve Yapay Zeka Asistanları** kullanılmıştır.

Bu nedenle repoda Flutter kurulumu, state management eğitimi veya adım adım çalıştırma kılavuzu **sunulmamaktadır.** Eğer kodları incelemek veya kendi sisteminize entegre etmek isterseniz, standart Flutter derleme süreçlerini (pub get, pod install) kendi ortamınızda uygulayabilirsiniz. Zlife ekibi olarak odak noktamız tamamen arka plandaki Makine Öğrenimi (Sol Lob) ve verinin Apple HealthKit üzerinden güvenle işlenmesidir.

---

> **Zcore AI Health Project** - Geleceğin sağlık asistanı.
