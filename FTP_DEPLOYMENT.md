# FTP Deployment Guide

Panduan ini menjelaskan cara deploy perubahan backend ke hosting `stundaa.com` memakai script lokal `ftp_sync.py`.

## Konteks

- Script deploy: `ftp_sync.py`
- Folder lokal yang di-upload: `backend stundaa/public_html`
- Folder remote hosting: `/domains/stundaa.com/public_html`
- Koneksi: FTPS explicit TLS lewat port `21`
- State perubahan file: `.ftp_state.json`

`ftp_sync.py` tidak di-commit ke Git karena berisi konfigurasi deployment lokal. Jangan paksa commit file ini.

## Aturan Keamanan

Jangan pernah menulis credential langsung di file script, dokumentasi, atau commit Git.

Credential FTP harus diberikan lewat environment variable:

```powershell
$env:FTP_USER="user-ftp-kamu"
$env:FTP_PASSWORD="password-ftp-kamu"
```

Opsional, kalau host atau port berubah:

```powershell
$env:FTP_HOST="stundaa.com"
$env:FTP_PORT="21"
$env:FTP_TLS="1"
```

Jangan upload file rahasia ke `public_html`, termasuk:

- `.env`
- `cred.txt`
- file database dump `.sql`
- file key seperti `.pem`, `.key`, `.jks`
- file backup `.zip` berisi source atau credential

## Cara Cek Perubahan

Selalu jalankan dry-run sebelum upload:

```powershell
python .\ftp_sync.py --dry-run
```

Dry-run hanya menampilkan file yang akan di-upload. Tidak ada file yang dikirim ke server.

Kalau output dry-run menampilkan ribuan file, jangan langsung upload penuh. Gunakan `--only` untuk file yang memang berubah.

## Upload File Tertentu

Ini cara yang paling aman untuk deploy perubahan kecil:

```powershell
python .\ftp_sync.py --only "routes/web.php" --yes
```

Bisa upload beberapa file sekaligus:

```powershell
python .\ftp_sync.py --only "routes/web.php" --only "resources/views/vendors/vendor-dashboard.blade.php" --yes
```

Path untuk `--only` harus relatif dari:

```text
backend stundaa/public_html
```

Contoh benar:

```text
app/Yantrana/Components/WhatsAppService/WhatsAppServiceEngine.php
resources/views/vendors/vendor-dashboard.blade.php
routes/web.php
```

Contoh salah:

```text
backend stundaa/public_html/routes/web.php
```

## Upload Semua Perubahan

Gunakan hanya kalau dry-run sudah dicek dan daftar file memang benar:

```powershell
python .\ftp_sync.py --yes
```

Setelah upload sukses, script memperbarui `.ftp_state.json` agar upload berikutnya hanya mengirim file yang hash-nya berubah.

## Cara Kerja Script

1. Script scan semua file di `backend stundaa/public_html`.
2. File yang masuk daftar ignore dilewati.
3. Tiap file dihitung hash MD5-nya.
4. Hash saat ini dibandingkan dengan `.ftp_state.json`.
5. File yang hash-nya berubah akan di-upload.
6. Script login ke FTP memakai FTPS/TLS.
7. Folder remote dibuat kalau belum ada.
8. File di-upload memakai perintah FTP `STOR`.
9. Jika semua upload sukses, `.ftp_state.json` diperbarui.

## Catatan Penting Untuk Agent

- Jangan mengubah `remote_root` kecuali user memang meminta deploy ke folder lain.
- Jangan menjalankan upload penuh kalau dry-run menampilkan ribuan file tanpa konfirmasi user.
- Jangan membuka, menyalin, atau menampilkan isi file credential.
- Jangan commit `ftp_sync.py`, `.ftp_state.json`, `.env`, atau `cred.txt`.
- Kalau upload gagal sebagian, cek daftar `FAIL` di output dan ulangi hanya file yang gagal dengan `--only`.
- Script saat ini mendeteksi file terhapus, tetapi tidak menghapus file remote dari server.

## Troubleshooting

Jika muncul error environment variable belum ada:

```powershell
$env:FTP_USER="user-ftp-kamu"
$env:FTP_PASSWORD="password-ftp-kamu"
```

Jika login gagal:

- Pastikan password FTP benar.
- Pastikan user FTP masih aktif di cPanel.
- Pastikan akun FTP punya akses ke folder `public_html`.

Jika koneksi timeout:

- Coba ulang setelah beberapa menit.
- Pastikan jaringan tidak memblokir FTP/FTPS port `21`.
- Pastikan hosting tidak membatasi IP sementara.

Jika file tidak ikut upload:

- Pastikan path `--only` relatif dari `backend stundaa/public_html`.
- Pastikan file tidak masuk daftar ignore di `ftp_sync.py`.
- Jalankan `python .\ftp_sync.py --dry-run` untuk melihat status perubahan.
