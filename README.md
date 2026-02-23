# ⚔️ Legendary Armory - RPG Weapon Shop

Aplikasi toko online berbasis Flutter dengan tema RPG Fantasy Weapon Shop. Proyek ini dibuat untuk memenuhi tugas "Shopping Cart Enhancement".

**Nama:** Dharma Pala Candra  
**NIM:** 2409116065  
**Mata Kuliah:** Pemogramman Aplikasi Bergerak  

## 📱 Preview
| Home & Search | Cart & Quantity | Checkout Form |
|:---:|:---:|:---:|
| <img width="381" height="534" alt="Home" src="https://github.com/user-attachments/assets/d25054e2-fd90-4e9e-8342-913666ba34bb" />| <img width="381" height="536" alt="cart" src="https://github.com/user-attachments/assets/a1359743-b11c-4d2f-8eac-eb21b712932a" />|<img width="381" height="537" alt="checkout" src="https://github.com/user-attachments/assets/3ece2d22-865f-4e16-92aa-e6d8d25a719e" />|

*(Catatan: Gambar screenshot disimpan di folder `Dokumentasi SS`)*

## ✅ Fitur & Poin Penilaian

Aplikasi ini telah memenuhi **100 Poin** kriteria tugas:

### WAJIB (70 Points)
- [x] **Add to cart:** Menambahkan item ke keranjang dari list produk.
- [x] **Show cart items:** Menampilkan list item dengan jumlah quantity.
- [x] **Update quantity:** Tombol (+) dan (-) berfungsi update real-time.
- [x] **Remove items:** Item otomatis terhapus jika quantity 0 atau ditekan tombol hapus.
- [x] **Display total price:** Total harga terhitung otomatis.

### BONUS (30 Points)
- [x] **Search Products (+10):** Pencarian real-time berdasarkan nama senjata.
- [x] **Categories Filter (+10):** Filter berdasarkan kategori (Melee, Ranged, Magic, Armor).
- [x] **Checkout Page (+10):** Halaman ringkasan order dan form validasi pengiriman.

## 🛠️ Teknologi yang Digunakan
- **Flutter SDK**
- **Provider** (State Management)
- **Placehold.co** (Dynamic Image Generation)

## 🚀 Cara Instalasi & Run

1. **Clone Repository**
   ```bash
   git clone [
---

### 2. Penjelasan Lengkap Kodingan (Alur Logika)

**A. Data Layer (Model)**
* Kita punya dua kelas utama: `Product` (untuk data barang) dan `CartItem` (untuk barang yang masuk keranjang, lengkap dengan jumlah `quantity`).

**B. State Management (`StoreProvider`)**
* Ini adalah "Otak" aplikasi. Menggunakan `ChangeNotifier` dari package `provider`.
* **Data Dummy:** Menggunakan `List.generate` untuk membuat 40 barang otomatis agar kode tetap pendek tapi datanya banyak.
* **Logika Cart:** Menggunakan `Map<String, CartItem>` agar pencarian dan update barang lebih cepat (O(1)) dibanding menggunakan List biasa.
* **Filter Logic:** Fungsi `get products` melakukan filter ganda: cek apakah nama cocok dengan *search query* DAN apakah kategori cocok dengan *selected category*.

**C. UI Layer (Tampilan)**
* **ProductListScreen:** Menampilkan GridView. Menggunakan `Consumer` atau `Provider.of` untuk mendengarkan perubahan data saat filter diklik.
* **CartScreen:** Menampilkan ListView dari isi keranjang. Tombol `+` dan `-` memanggil fungsi di Provider yang langsung memperbarui tampilan total harga secara otomatis.
* **CheckoutScreen:** Menggunakan `Form` dan `TextFormField` dengan validator bawaan Flutter untuk memastikan data tidak kosong sebelum order diproses.

---

### 3. Argumen: Kenapa Hanya Menggunakan `main.dart`?

**1. Portabilitas & Kemudahan Review (Assignment Context)**
> *"Untuk tugas skala kecil hingga menengah seperti ini, struktur file tunggal memudahkan proses pengiriman dan penilaian. Dosen/Asisten dapat membaca alur logika (Model -> State -> UI) secara linear dari atas ke bawah tanpa perlu melompat-lompat antar file (Context Switching)."*

**2. Mengurangi Boilerplate Code**
> *"Dengan menyatukan kode, kita menghilangkan kebutuhan akan puluhan baris kode `import` antar file. Ini membuat kode lebih padat dan fokus pada logika bisnis fitur shopping cart."*

**3. State Management Terpusat**
> *"Meskipun satu file, kode tetap terstruktur rapi karena kita memisahkan Class Model, Provider, dan Widget Screen. Penggunaan `ChangeNotifierProvider` di root (`main`) membuktikan bahwa aplikasi ini tetap mengikuti prinsip reactive programming Flutter meskipun berada dalam satu file fisik."*

**4. Efisiensi Pengembangan (Prototyping)**
> *"Pendekatan ini mensimulasikan rapid prototyping. Dalam pengembangan nyata, seringkali developer membuat fitur dalam satu file dulu untuk menguji kelayakan, baru kemudian di-refactor (dipecah) saat kode mulai kompleks. Untuk lingkup tugas 40 item ini, single file adalah pendekatan yang paling efisien (KISS Principle - Keep It Simple, Stupid)."*

**Kesimpulan:**
"Saya memahami *Best Practice* pemisahan file (MVVM/MVC), namun untuk efisiensi tugas ini, saya memilih struktur *monolithic* yang terorganisir di dalam `main.dart` agar mudah dijalankan dan didebug."

