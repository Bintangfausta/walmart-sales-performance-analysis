# Walmart Retail Branch Performance and Sales Trend Analysis, 2022–2023

## 1. Executive Summary

Proyek ini menganalisis data transaksi penjualan di berbagai cabang Walmart untuk mengungkap faktor operasional dan pendorong revenue di balik performa masing-masing cabang. Analisis ini tidak berhenti pada pelaporan sederhana, melainkan menjawab pertanyaan bisnis inti: **cabang, kategori, dan perilaku pelanggan mana yang mendorong — atau justru menghambat — revenue, dan apa yang harus dilakukan manajemen terhadap hal tersebut?**

### Business Goals & Objectives

- Mengidentifikasi kategori produk dan cabang mana yang secara konsisten memberikan customer satisfaction dan profitability tertinggi.
- Memahami preferensi metode pembayaran pelanggan untuk menginformasikan strategi point-of-sale dan kemitraan.
- Mendeteksi periode puncak operasional (hari dalam seminggu, waktu dalam sehari) untuk mengoptimalkan staffing dan alokasi inventory.
- Mengkuantifikasi performa revenue Year-over-Year (2022 vs. 2023) di level cabang untuk menandai lokasi yang underperform agar bisa ditindaklanjuti manajemen.
- Menerjemahkan data transaksi mentah menjadi insight dan rekomendasi strategis yang siap dipakai untuk pengambilan keputusan oleh retail leadership.

---

## 2. Tech Stack / Tools Used

| Layer | Tools |
|---|---|
| Data Cleaning & Integration | Python, Pandas |
| Database | PostgreSQL |
| Data Loading (ETL) | SQLAlchemy, psycopg2 |
| Analysis & Querying | SQL (CTEs, Window Functions, Aggregations) |
| Environment | Jupyter Notebook |

---

## 3. Business Problems Addressed

Analisis ini disusun berdasarkan pertanyaan-pertanyaan bisnis berikut:

1. Apa metode pembayaran yang paling banyak digunakan, dan berapa jumlah transaksi serta unit terjual untuk masing-masing metode pembayaran?
2. Kategori produk mana yang memperoleh rating rata-rata pelanggan tertinggi di setiap cabang?
3. Hari apa dalam seminggu yang paling sibuk (berdasarkan volume transaksi) untuk setiap cabang?
4. Berapa total kuantitas barang yang terjual, dipecah berdasarkan metode pembayaran?
5. Berapa rating produk rata-rata, minimum, dan maksimum berdasarkan kota dan kategori?
6. Kategori produk mana yang menghasilkan total profit tertinggi (unit price × quantity × profit margin)?
7. Apa metode pembayaran yang paling disukai di masing-masing cabang?
8. Bagaimana volume penjualan berubah across shift Morning, Afternoon, dan Evening?
9. Cabang mana yang menunjukkan penurunan revenue paling tinggi dari 2022 ke 2023, dan berapa besar penurunannya?

---

## 4. Data Pipeline & Methodology

Proyek ini mengikuti alur kerja standar **ETL → Analysis**, terbagi menjadi dua tahap:

**Stage 1 — Data Cleaning & Integration (Python / Pandas)**
- Mengimpor dataset mentah (**10.051 baris × 11 kolom**) dari `Walmart.csv`.
- Melakukan pengecekan kualitas data menggunakan `.info()`, `.describe()`, dan `.isnull().sum()` untuk memprofilkan tipe data, missing values, dan outlier statistik.
- Menghapus transaksi duplikat persis menggunakan `drop_duplicates()`.
- Membuang record tidak lengkap yang mengandung missing values (`dropna()`), sehingga dataset berkurang menjadi **9.969 baris bersih**.
- Membersihkan kolom `unit_price` dengan menghilangkan simbol mata uang (`$`) dan mengubahnya menjadi tipe numerik (float) untuk keperluan perhitungan.
- Menstandarkan penamaan kolom menjadi huruf kecil agar konsisten dengan query SQL.
- Membuat kolom baru `total` (`unit_price × quantity`) untuk merepresentasikan revenue di level transaksi.
- Mengekspor dataset yang sudah bersih ke `walmart_clean_data.csv` dan memuatnya ke database PostgreSQL (tabel `walmart`) melalui `SQLAlchemy`, dengan query validasi row-count untuk memastikan proses loading berhasil dan tidak ada data yang hilang.

**Stage 2 — Exploratory Data Analysis & Business Querying (SQL / PostgreSQL)**
- Melakukan query pada tabel `walmart` yang sudah bersih langsung di PostgreSQL untuk menjawab masing-masing dari sembilan business problem di atas.
- Menerapkan agregasi `GROUP BY` untuk merangkum metode pembayaran, rating, dan kuantitas.
- Menggunakan logika `CASE WHEN` untuk mensegmentasi transaksi ke dalam shift Morning / Afternoon / Evening berdasarkan timestamp transaksi.
- Memanfaatkan **Window Functions** (`RANK() OVER (PARTITION BY ...)`) untuk mengidentifikasi kategori, hari, dan metode pembayaran dengan ranking tertinggi *per cabang*, bukan secara global.
- Membangun **CTEs (Common Table Expressions)** untuk memisahkan revenue 2022 dan 2023 per cabang, lalu **join** kedua periode tersebut untuk menghitung rasio penurunan revenue Year-over-Year, sehingga memunculkan lima cabang yang paling membutuhkan perhatian strategis.

---

## 5. Key Business Insights & Recommendations

Query-query pada Section 3 disintesis menjadi insight berikut, masing-masing dipasangkan dengan rekomendasi konkret untuk retail leadership. Angka-angka diambil langsung dari dataset yang sudah bersih (9.969 transaksi, 100 cabang, 98 kota), yang mencatat total revenue sebesar **$1.209.726** dan total profit sebesar **$476.139**.

**Insight 1 — Dua Kategori Menyumbang ~81% dari Total Profit, Terlepas dari Margin**
- `Fashion Accessories` ($192.315) dan `Home and Lifestyle` ($192.214) bersama-sama menghasilkan sekitar 81% dari total profit, sementara empat kategori lainnya masing-masing hanya menyumbang $18K–$31K.
- Rata-rata profit margin hampir seragam di keenam kategori (0,38–0,40), yang berarti gap ini sepenuhnya didorong oleh sales volume, bukan oleh harga atau efisiensi margin.
- **Rekomendasi:** Prioritaskan kedalaman inventory, penempatan rak, dan budget promosi ke `Fashion Accessories` dan `Home and Lifestyle`. Untuk kategori dengan volume lebih rendah, fokus pada taktik pendorong volume (bundling, cross-selling) alih-alih penyesuaian margin, karena margin bukan faktor pembatas di sini.

**Insight 2 — Preferensi Metode Pembayaran per Cabang Berbeda dari Rata-rata Network**
- Di level network, `Credit Card` memimpin dari sisi total transaksi (4.256), diikuti `Ewallet` (3.881) dan `Cash` (1.832).
- Namun jika diukur per cabang, `Ewallet` menjadi metode pembayaran teratas di 75 dari 100 cabang, dibandingkan `Credit Card` di 23 cabang dan `Cash` hanya di 2 cabang.
- **Rekomendasi:** Adopsi `Ewallet` bersifat luas di seluruh jaringan cabang, bukan terkonsentrasi di beberapa lokasi saja, sehingga menjadikannya investasi dengan leverage tertinggi untuk strategi POS (uptime, kecepatan checkout, promosi cashback). Penggunaan `Cash` kemungkinan bisa mulai dikurangi mengingat porsinya yang konsisten rendah.

**Insight 3 — Customer Satisfaction Tergolong Moderat Secara Keseluruhan, dengan Variasi Regional yang Lebar**
- Rata-rata rating produk di seluruh transaksi adalah 5,83 / 10.
- Rata-rata rating di level kota berkisar dari ~5,0 (Rowlett, Texas City, Sherman) hingga ~7,0 (Austin, Huntsville, Pflugerville) — selisih sekitar dua poin penuh antara pasar terlemah dan terkuat.
- **Rekomendasi:** Lakukan audit kualitas layanan di kota-kota dengan rating terendah, dengan fokus pada ketersediaan stok, kecepatan checkout, dan kondisi toko. Jadikan cabang dengan performa terbaik seperti Austin sebagai benchmark internal untuk best practice.

**Insight 4 — Kategori dengan Profit Tertinggi Justru Paling Jarang Menjadi yang Top-Rated**
- `Food and Beverages` dan `Sports and Travel` sama-sama menjadi kategori yang paling sering top-rated di berbagai cabang (masing-masing 26 cabang), diikuti oleh `Health and Beauty` (25) dan `Electronic Accessories` (19).
- Sebaliknya, `Fashion Accessories` dan `Home and Lifestyle` — dua kontributor profit terbesar dari Insight 1 — hanya menempati peringkat #1 rating di masing-masing 3 dan 2 cabang.
- **Rekomendasi:** Tandai hal ini ke leadership sebagai risiko churn: kategori yang menghasilkan profit terbesar bukanlah kategori yang paling memuaskan pelanggan. Review kualitas produk dan customer experience yang ditargetkan di kedua kategori ini bisa melindungi porsi total profit yang signifikan.

**Insight 5 — Aktivitas Penjualan Terkonsentrasi di Siang Hari, Pagi Hari Kurang Termanfaatkan**
- Volume transaksi per shift: Afternoon 46% (4.636 invoice), Evening 33% (3.246), Morning hanya 21% (2.087).
- **Rekomendasi:** Selaraskan level staffing dengan kurva permintaan ini, dengan mengonsentrasikan jumlah staf di shift Afternoon dan Evening. Perkenalkan promosi "morning deal" yang dibatasi waktu untuk mendistribusikan ulang traffic dan meningkatkan throughput toko di jam pagi yang lebih sepi.

**Insight 6 — Hari Tengah Minggu, Bukan Akhir Pekan, Menjadi Puncak yang Paling Umum**
- Thursday paling sering menjadi hari tersibuk di berbagai cabang (23 cabang), diikuti Tuesday dan Wednesday (21 masing-masing); Friday adalah hari yang paling jarang menjadi puncak suatu cabang (hanya 8 cabang).
- **Rekomendasi:** Bobotkan jadwal staffing dan replenishment inventory ke arah window Tuesday–Thursday, alih-alih default ke asumsi akhir pekan yang ramai. Validasi pola ini secara regional, karena kemungkinan mencerminkan siklus payday lokal atau kebiasaan belanja setempat.

**Insight 7 — Pertumbuhan Agregat Menutupi Penurunan Tajam di Sejumlah Kecil Cabang**
- Revenue network-wide tumbuh dari $217.405 (2022) menjadi $232.260 (2023), kenaikan 6,8%, yang sekilas menunjukkan stabilitas secara keseluruhan.
- Namun, lima cabang mencatat penurunan year-over-year yang tajam: WALM045 (-62,6%), WALM047 (-58,6%), WALM098 (-57,9%), WALM033 (-55,6%), dan WALM081 (-50,7%).
- **Rekomendasi:** KPI di level agregat tidak boleh menjadi satu-satunya dasar evaluasi performa, karena bisa menutupi masalah lokal. Kelima cabang ini memerlukan investigasi root-cause segera — kemungkinan penyebabnya termasuk kompetitor lokal baru, gangguan inventory atau staffing, atau perubahan pada basis pelanggan di sekitar toko.

---

## 6. Repository Structure

```
walmart-sales-performance-analysis/
│
├── README.md                          # Project overview and business insights
├── data/
│   ├── Walmart.csv                    # Raw source dataset (10,051 rows)
│   └── walmart_clean_data.csv         # Cleaned dataset after Python processing (9,969 rows)
│
├── walmart_data_cleaning.ipynb        # Data cleaning, feature engineering & PostgreSQL loading (Python/Pandas)
│
├── eda_business_questions.sql         # Exploratory data analysis & 9 business problem queries (PostgreSQL)
│
└── assets/                            # (Optional) Charts, dashboard screenshots, or exported visuals
```

---

### Author's Note
Proyek ini mendemonstrasikan end-to-end analytics workflow — mulai dari data transaksi mentah yang berantakan hingga menjadi relational database yang bersih, dilanjutkan dengan business intelligence berbasis SQL — mencerminkan jenis analisis yang akan disampaikan seorang retail data analyst untuk mendukung pengambilan keputusan di level cabang.
