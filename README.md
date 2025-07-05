# IP-TV Oynatıcı

Bu proje, Flutter ile geliştirilmiş basit bir IPTV oynatıcı uygulamasıdır. Kullanıcıların M3U8 formatındaki canlı TV yayınlarını izlemesine olanak tanır.

## ✨ Özellikler

- **Kategorize Edilmiş Kanallar:** TV kanalları, spor, haber gibi sekmeler altında düzenlenmiştir.
- **Dahili Video Oynatıcı:** `video_player` ve `chewie` paketlerini kullanarak akıcı bir izleme deneyimi sunar.
- **Arama Fonksiyonu:** Kullanıcıların istedikleri kanalı kolayca bulmasını sağlar.
- **Kullanıcı Dostu Arayüz:** Modern ve karanlık tema destekli bir tasarıma sahiptir.
- **Tam Ekran Desteği:** Yayınları tam ekran modunda izleme imkanı sunar.

## 🛠️ Kullanılan Teknolojiler

- **Flutter:** Google tarafından geliştirilen, tek bir kod tabanından mobil, web ve masaüstü için güzel, yerel olarak derlenmiş uygulamalar oluşturmaya yönelik kullanıcı arayüzü araç takımı.
- **Dart:** İstemci tarafında optimize edilmiş, hızlı uygulamalar geliştirmek için kullanılan bir programlama dili.
- **Paketler:**
  - `video_player`: Video dosyalarını oynatmak için temel bir eklenti.
  - `chewie`: `video_player` için özelleştirilebilir kontroller sunan bir sarmalayıcı.
  - `flutter_vlc_player`: Alternatif bir video oynatıcı seçeneği.

## 🚀 Projeyi Başlatma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

1. **Depoyu klonlayın:**
   ```sh
   git clone https://github.com/Umut-cann/IP-TV.git
   ```
2. **Proje dizinine gidin:**
   ```sh
   cd IP-TV
   ```
3. **Gerekli paketleri yükleyin:**
   ```sh
   flutter pub get
   ```
4. **Uygulamayı çalıştırın:**
   ```sh
   flutter run
   ```

## 📝 Nasıl Çalışır?

Uygulama, `lib/dataM3u/data.dart` dosyası içinde önceden tanımlanmış bir TV kanalı listesini yükler. Bu kanallar, kategorilere ayrılmış sekmeler halinde kullanıcı arayüzünde görüntülenir. Kullanıcı bir kanala tıkladığında, ilgili M3U8 yayını dahili video oynatıcı ile oynatılmaya başlar.
