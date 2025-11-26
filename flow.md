Baik, saya akan breakdown semua flow yang ada dari ketiga dokumen tersebut secara detail dan terstruktur.

## 📱 **BREAKDOWN FLOW APLIKASI BANK SAMPAH**

### 🔐 **AUTHENTICATION FLOW**

#### **Register Nasabah**
```
1. Input: username, nomor handphone, password, email
2. Button: Daftar
3. Verifikasi: OTP
4. Outcome: Akun nasabah terbuat
```

#### **Login (Nasabah & Driver)**
```
- Input: username/nomor handphone + password
- Validation: Credential check
- Redirect: Ke beranda sesuai role
```

#### **Lupa Password**
```
1. Input: email/username
2. Submit: Request reset
3. Verifikasi: OTP/kode verifikasi
4. Input: Password baru + konfirmasi
5. Outcome: Popup "Password Berhasil Diubah"
```

---

## 👤 **NASABAH FLOW**

### **Beranda Nasabah**
```
├── Headline/Slider promo
├── List kategori sampah
├── Navigation:
│   ├── Beranda
│   ├── Profile
│   ├── Riwayat Transaksi
│   └── Pengajuan/Nabung
└── Quick access menu
```

### **Profile Management**
```
Edit Profile:
├── Nama (textbox)
├── Nomor handphone (textbox)
├── Photo/avatar
├── Email (textbox)
├── Alamat lengkap (textarea)
├── Geolocation
└── Button: Simpan

Ubah Password:
├── Input password lama
├── Input password baru
├── Konfirmasi password baru
└── Submit
```

### **Pengajuan Sampah Flow**
```
1. Pilih kategori sampah
2. Input jumlah/berat
3. Sistem kalkulasi: subtotal & total
4. Alamat (auto-filled, bisa edit)
5. Submit pengajuan
6. Status: Proses → Driver assign → Selesai/Dibatalkan
```

### **Pencairan Saldo Flow**
```
1. Cek saldo yang dapat dicairkan
2. Verifikasi minimum pencairan
3. Pilih metode: cash atau saldo
4. Input jumlah pencairan
5. Submit pengajuan
6. Status: Pending → Terverifikasi → Dibatalkan
```

### **Riwayat & Tracking**
```
Riwayat Transaksi:
├── Nomor Transaksi
├── Kategori List
├── Sub Total per Kategori
├── Total Keseluruhan
├── Tanggal Transaksi
└── Status (Proses, Dibatalkan, Selesai)

Riwayat Pencairan:
├── Nomor Transaksi Pencairan
├── Jumlah yang dicairkan
├── Tanggal
├── Status (Terverifikasi, Pending, Dibatalkan)
└── Foto transfer/bukti
```

---

## 🚚 **DRIVER FLOW**

### **Beranda Driver**
```
├── List penjemputan aktif
├── Inbox pesan
├── Navigation:
│   ├── Beranda
│   ├── Profile
│   └── Riwayat Penjemputan
└── Quick actions
```

### **Penjemputan Process**
```
1. Terima list penjemputan dari sistem
2. Buka detail penjemputan:
   ├── Alamat Detail
   ├── Maps Embed
   ├── Informasi sampah
   └── Kontak nasabah
3. Approve penjemputan
4. Update status: Sedang dijemput → Sampai lokasi
5. Edit pengajuan sampah (jika kuantitas tidak sesuai)
6. Approve dan Selesai
```

### **Driver Profile & Management**
```
Sama dengan nasabah plus:
├── Geolocation tracking
├── Availability status
└── Performance metrics
```

---

## 🔄 **CROSS-FUNCTIONAL FLOWS**

### **Transaksi Sampah End-to-End**
```
Nasabah:
1. Ajukan sampah → 2. Tunggu driver → 3. Konfirmasi penerimaan

Driver:
1. Terima penjemputan → 2. Jemput sampah → 3. Input kuantitas aktual → 4. Approve selesai

System:
1. Update saldo nasabah → 2. Update riwayat → 3. Notifikasi kedua pihak
```

### **Inbox & Notifikasi**
```
Pesan meliputi:
├── Notifikasi transaksi
├── Update status penjemputan
├── Informasi dari admin
└── Pesan broadcast

Format:
├── Isi pesan
├── Tanggal pesan
├── Status baca
└── Tipe pesan (internal/eksternal)
```

---

## ⚠️ **SPECIAL CASES & EXCEPTIONS**

### **Edit Pengajuan Sampah**
- **Kondisi**: Ketika kuantitas sampah tidak sesuai di lapangan
- **Aktor**: Driver
- **Action**: Edit kuantitas aktual sebelum approve
- **Impact**: Penyesuaian saldo nasabah

### **Minimum Pencairan**
- Validasi minimum amount sebelum pengajuan pencairan
- Sistem tolak jika tidak memenuhi minimum

### **Geolocation Integration**
- Maps embed untuk driver
- Alamat detail dengan koordinat
- Navigation assistance

---

## 🎯 **SUMMARY KEY FEATURES**

| Module | Nasabah | Driver | Admin |
|--------|---------|--------|-------|
| Auth | ✅ | ✅ | ❓ |
| Profile Management | ✅ | ✅ | ❓ |
| Pengajuan Sampah | ✅ | ❌ | ❓ |
| Penjemputan | ❌ | ✅ | ❓ |
| Pencairan Saldo | ✅ | ❌ | ❓ |
| Riwayat Transaksi | ✅ | ✅ | ❓ |
| Inbox Pesan | ✅ | ✅ | ❓ |

Apakah Anda ingin saya detailkan lebih lanjut untuk flow tertentu atau membuat diagram visual dari breakdown ini?