# Testing Guide - Bank Sampah Alma Magelang

## Prerequisites

### 1. Setup Aplikasi
```bash
# Clone repository (jika belum)
cd D:\Github\zsd_bank_sampah_alma_magelang

# Install dependencies
flutter pub get

# Verify Flutter installation
flutter doctor
```

### 2. Persiapan Device
- **Emulator/Simulator**: Buka Android Emulator atau iOS Simulator
- **Physical Device**: Hubungkan device via USB dengan USB Debugging enabled
- **WhatsApp**: Pastikan WhatsApp terinstall di device untuk testing fitur chat

### 3. Run Aplikasi
```bash
# List available devices
flutter devices

# Run di device tertentu
flutter run -d <device-id>

# Atau run dengan hot reload
flutter run
```

---

## Demo Credentials

### 👤 Nasabah Account
```
Username: dewi123
Password: nasabah123
```
**Data Nasabah:**
- Nama: Dewi Lestari
- Balance: Rp 250,000
- Withdrawable: Rp 200,000

### 🚗 Driver Account
```
Username: budi_driver
Password: driver123
```
**Data Driver:**
- Nama: Budi Santoso
- Vehicle: B 1234 XYZ
- Status: Tersedia

### 👨‍💼 Admin Account
```
Username: admin
Password: admin123
```
**Data Admin:**
- Nama: Admin Bank Sampah
- Access: Full management

---

## Testing Flow: NASABAH MODULE

### 1. Login & Beranda ✓

**Steps:**
1. Buka aplikasi
2. Pilih role chip **"Nasabah"**
3. Input username: `dewi123`
4. Input password: `nasabah123`
5. Tap button **"Masuk"**

**Expected Results:**
- ✓ Loading indicator muncul
- ✓ Navigate ke Beranda Nasabah
- ✓ Greeting "Selamat Datang, Dewi Lestari"
- ✓ Balance card menampilkan Rp 250,000
- ✓ Withdrawable balance Rp 200,000
- ✓ 3 quick action buttons visible
- ✓ Grid 6 kategori sampah dengan icons & harga
- ✓ Info banner tampil
- ✓ Bottom navigation 4 tabs

### 2. Pengajuan Sampah ✓

**Steps:**
1. Dari Beranda, tap button **"Ajukan Sampah"** atau tab **"Pengajuan"**
2. Pilih minimal 2 kategori dengan checkbox (contoh: Plastik & Kertas)
3. Input berat untuk Plastik: `5` kg
4. Input berat untuk Kertas: `3` kg
5. Verifikasi alamat (pre-filled, bisa edit)
6. Tap button **"Ajukan Penjemputan"**

**Expected Results:**
- ✓ Kategori yang dipilih aktif (checkmark)
- ✓ Subtotal auto-calculate: Plastik = 5 × 2000 = Rp 10,000
- ✓ Subtotalkertas = 3 × 1500 = Rp 4,500
- ✓ Total card menampilkan: Rp 14,500
- ✓ Button enabled setelah data valid
- ✓ Success SnackBar muncul
- ✓ Form reset setelah submit

**Edge Cases:**
- [ ] Submit tanpa pilih kategori → Should show error
- [ ] Submit dengan berat kosong → Should show validation
- [ ] Submit dengan berat 0 atau negative → Should show error

### 3. Pencairan Saldo ✓

**Steps:**
1. Tap button **"Cairkan Saldo"** di quick actions
2. Lihat balance yang bisa dicairkan
3. Baca info rules (minimum Rp 50,000)
4. Input amount: `100000`
5. Pilih method: **"Transfer Bank"**
6. Tap **"Ajukan Pencairan"**
7. Confirm dialog

**Expected Results:**
- ✓ Withdrawable balance: Rp 200,000 tampil
- ✓ Info card dengan rules visible
- ✓ Amount validation realtime
- ✓ Method selection cards clickable
- ✓ Button enabled jika amount valid
- ✓ Success dialog muncul
- ✓ Navigate back ke Beranda

**Edge Cases:**
- [ ] Input amount < Rp 50,000 → Error "Minimum pencairan"
- [ ] Input amount > balance → Error "Saldo tidak cukup"
- [ ] Input 0 atau kosong → Button disabled

### 4. Riwayat Transaksi ✓

**Steps:**
1. Tap tab **"Riwayat"** di bottom navigation
2. Lihat list transaksi (should have dummy data)
3. Tap filter chip **"Proses"**
4. Tap salah satu transaction card
5. Lihat detail modal
6. **Test WhatsApp:** Jika driver assigned, tap **"Hubungi Driver via WhatsApp"**
7. Verify WhatsApp terbuka dengan pesan pre-filled

**Expected Results:**
- ✓ List transactions tampil dengan cards
- ✓ Filter chips working (All, Proses, Dijemput, Selesai, Dibatalkan)
- ✓ Status badges warna berbeda per status
- ✓ Detail modal muncul dengan drag handle
- ✓ Transaction info lengkap (ID, date, status, items, total, address)
- ✓ WhatsApp button HANYA muncul jika driver assigned & status aktif
- ✓ WhatsApp opens dengan pesan: "Halo {driver}, saya ingin menanyakan tentang penjemputan sampah TRX-xxx"

**WhatsApp Testing:**
- [ ] Button hanya muncul jika `driverId != null`
- [ ] Button hanya muncul jika status = `proses` atau `dijemput`
- [ ] Tap button → WhatsApp app opens
- [ ] Phone number format correct (62xxx)
- [ ] Pre-filled message correct

### 5. Riwayat Pencairan ✓

**Steps:**
1. Dari Profile screen, tap **navigation** atau buat screen terpisah
2. Filter by **"Pending"**
3. Lihat withdrawal cards
4. Tap card untuk detail
5. Verify rejection reason jika status "Dibatalkan"

**Expected Results:**
- ✓ Filter chips working
- ✓ Withdrawal cards dengan status badges
- ✓ Amount & method displayed
- ✓ Detail modal complete
- ✓ Rejection reason tampil jika ada
- ✓ Proof indicator jika terverifikasi

### 6. Profile Management ✓

**Steps:**
1. Tap tab **"Profile"**
2. Tap **"Edit Profil"**
3. Change nama: `Dewi Lestari Updated`
4. Tap **"Simpan"**
5. Back dan verify name updated
6. Tap **"Ganti Password"**
7. Input old password: `nasabah123`
8. Input new password: `nasabah456`
9. Confirm password: `nasabah456`
10. Tap **"Simpan"**

**Expected Results:**
- ✓ Profile info cards tampil
- ✓ Edit form pre-filled dengan data existing
- ✓ Validation working (required, min length)
- ✓ Success feedback setelah save
- ✓ Change password validation working
- ✓ New password must differ from old
- ✓ Success dialog muncul

### 7. Logout

**Steps:**
1. Tap **"Keluar"** di Profile
2. Confirm dialog
3. Tap **"Logout"**

**Expected Results:**
- ✓ Confirmation dialog muncul
- ✓ Navigate back to Login screen
- ✓ Data cleared (tidak auto-login)

---

## Testing Flow: DRIVER MODULE

### 1. Login & Beranda ✓

**Steps:**
1. Login dengan username: `budi_driver`, password: `driver123`
2. Verify Beranda Driver

**Expected Results:**
- ✓ Driver info header (avatar, nama, vehicle, availability badge)
- ✓ Statistics cards (Penjemputan Aktif, Selesai Hari Ini)
- ✓ Active tasks list dengan cards
- ✓ Task cards showing customer, address, items, amount
- ✓ Bottom navigation 2 tabs (Beranda, Riwayat)

### 2. Detail Penjemputan ✓

**Steps:**
1. Tap salah satu task card dengan status **"proses"**
2. Lihat detail transaksi
3. **Test WhatsApp:** Tap **"Hubungi Nasabah via WhatsApp"**
4. Verify WhatsApp opens
5. Back ke detail
6. Tap button **"Mulai Penjemputan"**
7. Wait loading (2 detik)
8. Verify status berubah ke **"dijemput"**

**Expected Results:**
- ✓ Status card dengan badge
- ✓ Customer info (nama, alamat)
- ✓ WhatsApp button muncul di customer info section
- ✓ WhatsApp opens dengan pesan: "Halo {nasabah}, saya driver akan mengambil sampah Anda untuk TRX-xxx"
- ✓ Items list dengan weights
- ✓ Weights NOT editable (status masih proses)
- ✓ "Mulai Penjemputan" button visible
- ✓ Loading state working
- ✓ Success SnackBar muncul
- ✓ Status updated

### 3. Edit Quantities & Complete ✓

**Steps:**
1. Dari detail dengan status **"dijemput"**
2. Edit berat Plastik dari `5` menjadi `4.5`
3. Verify subtotal auto-recalculate
4. Verify grand total updated
5. Tap **"Simpan Perubahan"**
6. Wait loading
7. Tap button **"Selesai"**
8. Confirm
9. Verify navigate back

**Expected Results:**
- ✓ Weight fields EDITABLE (TextField muncul)
- ✓ Realtime calculation working
- ✓ "Simpan Perubahan" button visible
- ✓ Save success feedback
- ✓ "Selesai" button visible
- ✓ Complete success feedback
- ✓ Navigate back to Beranda
- ✓ Task pindah ke tab "Riwayat"

### 4. Riwayat Driver

**Steps:**
1. Tap tab **"Riwayat"**
2. Lihat completed tasks

**Expected Results:**
- ✓ Completed tasks list
- ✓ Status badges "Selesai"
- ✓ Can tap to view detail (read-only)

---

## Testing Flow: ADMIN MODULE

### 1. Login & Dashboard ✓

**Steps:**
1. Login dengan username: `admin`, password: `admin123`
2. Verify Dashboard

**Expected Results:**
- ✓ App title "Bank Sampah Alma Magelang"
- ✓ Statistics grid (4 cards dengan real-time counts)
- ✓ Menu cards (5 items)
- ✓ Pencairan Saldo dengan pending badge (jika ada)
- ✓ Refresh button di AppBar
- ✓ Pull-to-refresh working

### 2. User Management ✓

**Steps:**
1. Tap menu **"Manajemen Pengguna"**
2. Lihat tab Nasabah (should show 5 users)
3. Tap tab Driver (should show 3 users)
4. Pull-to-refresh
5. Verify FAB untuk "Tambah Driver"

**Expected Results:**
- ✓ Tab controller working
- ✓ Nasabah list dengan avatar, nama, username, phone, email, balance, status
- ✓ Driver list dengan avatar, nama, vehicle, availability status
- ✓ Pull-to-refresh working
- ✓ FAB visible di Driver tab
- ✓ Empty state handling

### 3. Withdrawal Management ✓

**Steps:**
1. Tap menu **"Pencairan Saldo"**
2. Verify filter default ke **"Pending"**
3. Pilih withdrawal dengan status pending
4. Tap **"Setujui"**
5. Confirm dialog
6. Verify success feedback
7. Pilih withdrawal lain
8. Tap **"Tolak"**
9. Input reason: "Data rekening tidak valid"
10. Confirm

**Expected Results:**
- ✓ List pending withdrawals
- ✓ Filter chips working
- ✓ Withdrawal cards dengan info lengkap
- ✓ Action buttons HANYA di pending
- ✓ Approve dialog dengan amount confirmation
- ✓ Reject dialog dengan reason input (required)
- ✓ Success feedback
- ✓ List refresh after action

### 4. Transaction Monitoring ✓

**Steps:**
1. Tap menu **"Monitoring Transaksi"**
2. Verify statistics banner (Total Transaksi, Total Nilai)
3. Filter by **"Selesai"**
4. Tap transaction card
5. Lihat detail modal

**Expected Results:**
- ✓ Statistics summary dengan gradient banner
- ✓ Real-time calculation by filter
- ✓ Filter chips working
- ✓ Transaction cards dengan nasabah, driver, items summary
- ✓ Detail modal complete
- ✓ Pull-to-refresh working

### 5. Category Management ✓

**Steps:**
1. Tap menu **"Kategori Sampah"**
2. Verify 12 categories tampil
3. Tap edit button di salah satu category
4. Change price dari `2000` ke `2500`
5. Tap **"Simpan"**
6. Verify FAB "Tambah Kategori"

**Expected Results:**
- ✓ Categories list dengan icon, nama, deskripsi, harga
- ✓ Edit button per category
- ✓ Edit dialog dengan price input
- ✓ Save success feedback
- ✓ FAB visible

### 6. Company Profile ✓

**Steps:**
1. Tap menu **"Profil Perusahaan"**
2. Lihat company info (view mode)
3. Tap edit icon di AppBar
4. Edit "Jam Operasional" dari `08:00-16:00` ke `08:00-17:00`
5. Edit "Minimum Pencairan" dari `50000` ke `75000`
6. Tap **"Simpan"**
7. Verify view mode kembali

**Expected Results:**
- ✓ View mode dengan InfoCards
- ✓ Logo placeholder dengan camera icon
- ✓ All fields displayed (7 fields)
- ✓ Edit mode toggle working
- ✓ Fields editable dengan pre-filled values
- ✓ Cancel button revert changes
- ✓ Save success feedback

---

## WhatsApp Integration Testing

### Prerequisites
- WhatsApp harus terinstall di testing device
- Phone number di dummy data harus valid format

### Test Case 1: Nasabah → Driver Contact
**Location:** Riwayat Transaksi > Detail Modal

**Steps:**
1. Login sebagai Nasabah
2. Navigate ke Riwayat Transaksi
3. Pilih transaction dengan `driverId != null` dan status `proses` atau `dijemput`
4. Tap "Hubungi Driver via WhatsApp"

**Expected:**
- WhatsApp opens
- Phone number: Driver's phone (format 62xxx)
- Pre-filled message: "Halo {driver.fullName}, saya ingin menanyakan tentang penjemputan sampah TRX-{transactionId}"

### Test Case 2: Driver → Nasabah Contact
**Location:** Detail Penjemputan > Customer Info Section

**Steps:**
1. Login sebagai Driver
2. Tap task card
3. Di customer info section, tap "Hubungi Nasabah via WhatsApp"

**Expected:**
- WhatsApp opens
- Phone number: Nasabah's phone (format 62xxx)
- Pre-filled message: "Halo {nasabah.fullName}, saya driver akan mengambil sampah Anda untuk TRX-{transactionId}"

### Test Case 3: Error Handling
**Steps:**
1. Uninstall WhatsApp dari device
2. Tap WhatsApp button
3. Verify error message

**Expected:**
- SnackBar dengan pesan error: "Tidak dapat membuka WhatsApp: ..."
- App tidak crash

---

## General Testing Checklist

### UI/UX ✓
- [ ] All screens responsive (landscape & portrait)
- [ ] Consistent color scheme (green primary, blue secondary, orange accent)
- [ ] Material 3 design visible
- [ ] Status badges warna sesuai (success=green, warning=orange, error=red, info=blue)
- [ ] Loading states tampil saat async operations
- [ ] Empty states friendly dengan icon & message
- [ ] Bottom navigation selected state clear

### Navigation ✓
- [ ] Back button working di semua screens
- [ ] Bottom navigation persistent
- [ ] Modal bottom sheets draggable
- [ ] Dialogs dapat di-dismiss
- [ ] Deep navigation working (detail → back → list)

### Data Display ✓
- [ ] Price formatting: Rp XXX,XXX (with comma)
- [ ] Date formatting: DD/MM/YYYY HH:MM
- [ ] Phone formatting: 0812-3456-7890
- [ ] Empty data handled gracefully
- [ ] Long text truncated dengan ellipsis

### Forms & Validation ✓
- [ ] Required fields marked
- [ ] Real-time validation
- [ ] Error messages clear
- [ ] Success feedback visible
- [ ] Form reset after submit
- [ ] Cancel button working

### Performance ⚠️
- [ ] App loads < 3 seconds
- [ ] Smooth scrolling (60fps)
- [ ] No jank during animations
- [ ] Memory usage reasonable
- [ ] No memory leaks after multiple navigations

---

## Bug Reporting Template

Jika menemukan bug, report dengan format berikut:

```markdown
## Bug Report

**Module:** [Nasabah/Driver/Admin]
**Screen:** [Nama screen]
**Priority:** [Critical/High/Medium/Low]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[Apa yang seharusnya terjadi]

**Actual Behavior:**
[Apa yang benar-benar terjadi]

**Screenshots:**
[Attach screenshots jika ada]

**Device Info:**
- OS: Android/iOS
- Version: 
- Device: 
- App Version: 

**Additional Notes:**
[Info tambahan]
```

---

## Known Limitations

☑️ **Data Persistence:**
- Data menggunakan dummy JSON
- Data **tidak persisten** setelah app restart
- Setiap restart akan reset ke dummy data

☑️ **Maps Integration:**
- Belum implemented (requires google_maps_flutter plugin)
- Koordinat location sudah ada di model

☑️ **Real Geolocation:**
- Belum implemented (requires geolocator plugin)
- Address field manual input only

☑️ **Image Upload:**
- Avatar & proof of payment belum bisa upload
- Hanya placeholder icon

☑️ **Real-time Sync:**
- Tidak ada real-time updates
- Perlu manual refresh (pull-to-refresh)

---

## Next Phase Testing (Future)

### When Backend is Ready:
1. **API Integration Testing**
   - Login authentication
   - CRUD operations
   - Real-time updates
   - Error handling (401, 404, 500, etc)

2. **Push Notifications**
   - Transaction status updates
   - Withdrawal approval
   - New pickup requests

3. **Advanced Features**
   - Google Maps navigation
   - Real geolocation
   - Image capture & upload
   - Report generation

---

## Support & Questions

Jika ada pertanyaan atau menemukan issue:
1. Check dokumentasi di `docs/`
2. Review code di relevant feature folders
3. Check dummy data di `assets/jsons/`

Happy Testing! 🚀
