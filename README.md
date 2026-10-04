# 📱 Kelime Öğren - Mobil Uygulama (Flutter)

Modern, zengin animasyonlu ve SRS (Aralıklı Tekrar) algoritması ile çalışan İngilizce kelime öğrenme mobil uygulaması.

---

## ✨ Özellikler

* **SRS (Aralıklı Tekrar) Sistemi:** SuperMemo-2 benzeri algoritma ile kelimelerin unutulma eğrisine göre tekrar planlaması.
* **Sesli Telaffuz (TTS):** Kelimeleri doğal İngilizce telaffuz ile dinleme desteği.
* **Oyunlaştırma & Mini Oyunlar:**
  * 3D Kart Çevirme (Flashcards)
  * Kelime Eşleştirme Oyunu (Match Game)
  * Hızlı Kelime Testi (Speed Game)
  * Harf Dizme / Yazma Pratiği (Spelling)
  * Dinleme & Anlama (Listening)
* **İstatistikler & Başarımlar:** Günlük seri (streak), haftalık başarı grafiği, kupa ve rozetler.
* **Offline-First & Senkronizasyon:** Çevrimdışı çalışabilme ve isteğe bağlı MongoDB / Supabase senkronizasyonu.

---

## 📁 Dizin Yapısı

```
mobile/
├── lib/
│   ├── main.dart
│   ├── config/              # Supabase & API yapılandırmaları
│   ├── models/              # Kelime, kategori, istatistik modelleri
│   ├── providers/           # AppProvider (State Management)
│   ├── repositories/        # Veri katmanı ve tohum verileri
│   ├── services/            # SRS, TTS, Local Storage, API & Supabase servisleri
│   ├── theme/               # Renk paleti ve Material 3 teması
│   └── ui/
│       ├── components/      # Navigasyon çubuğu, 3D kart, grafik bileşenleri
│       └── screens/         # Dashboard, Quiz, Flashcard, Oyun ekranları
├── test/                    # Birim ve widget testleri
└── pubspec.yaml             # Bağımlılıklar
```

---

## 🚀 Çalıştırma

1. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

2. **Ortam değişkenlerini hazırlayın:**
   `.env.example` dosyasını referans alarak `.env` dosyanızı oluşturun veya `--dart-define` ile parametreleri iletin.

3. **Uygulamayı başlatın:**
   ```bash
   flutter run
   ```

   *(Backend API ile birlikte test etmek için)*
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:3000
   ```
