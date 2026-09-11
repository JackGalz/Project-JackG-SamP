# Deploy Guide — Revitalize Roleplay (RVRP) SA-MP Server

## 1. Hosting: pakai apa?

SA-MP server 0.3.7 / 0.3DL **hanya jalan di Windows** (`samp037sv.exe`), jadi:

- **Pilih: Windows VPS** (bukan hosting web, bukan Render/Railway)
- **Spesifikasi minimal**: 2 vCPU, 4 GB RAM, 50 GB SSD, Windows Server 2019/2022
- **Lokasi**: Singapura / Jakarta / Jepang → ping kecil buat player Indonesia
- **Contoh provider**:
  - *Local*: Nickmerics, Sela, M4D (VPS Windows murah ~150-400rb/bulan)
  - *Luar*: Contabo (terbaik harga:fitur, ~$15/bulan), Hostinger KVM, RackNerd
- **Port yang harus dibuka di firewall**: `UDP 7777` (SA-MP). **JANGAN buka 3306** (MySQL) ke publik.

## 2. Siapkan Database (MySQL)

Gamemode pakai plugin `a_mysql` → butuh MySQL/MariaDB. Karena DB + server di VPS yang
sama, koneksi via `localhost` → aman, cepat, tanpa biaya tambahan.

1. Install **MySQL Server 8.0** (atau MariaDB 10.6):
   - Download: https://dev.mysql.com/downloads/installer/ (pilih "Server only"
     juga boleh, atau full)
   - Set **root password**, port 3306, binding **localhost only**
   - (Alternatif gampang: install XAMPP → aktifkan MySQL-nya)
2. Buat DB + user:
   ```
   mysql -u root -p
   ```
   lalu import isi `deploy/DB-setup.sql` (ganti dulu password-nya di file itu), atau
   langsung jalankan per baris di MySQL Workbench.
3. Import skema 31 tabel:
   ```
   mysql -u revitali -p revitali_rp < revitali_rp.sql
   ```
4. Cek:
   ```
   USE revitali_rp; SHOW TABLES;
   ```
   Harus muncul 31 tabel (characters, vehicle, dealer, houses, dll).

## 3. Unduh komponen server

| Komponen | Sumber |
|---|---|
| `samp037sv.exe` (server 0.3.7) | forum SA-MP / sa-mp.mp (atau build 0.3.DL komunitas jika player pakai 0.3DL) |
| `packr.exe` (kompilator Pawn 3.7.8-3347) | https://github.com/BlueGiraffee/SA-MP-Pawn-Compiler |
| `mysql.dll` | https://github.com/pBlueG/SA-MP-MySQL |
| `sscanf.dll` | https://github.com/maddinat0r/sscanf |
| `streamer.dll` | https://github.com/samp-incognito/samp-streamer-plugin |
| `bcrypt.dll` | https://github.com/Sreyas-Sreelal/samp-bcrypt |
| `pawnmem.dll` | https://github.com/BigETI/pawn-memory |
| YSI-Includes v1 | https://github.com/Y_Less/YSI-Includes (tag v1.x) |

> **PENTING — YSI**: repo ini BELUM berisi folder `YSI_Coding`, `YSI_Data`, `YSI_Server`
> (file `otherstuffs.rar` di include/ kemungkinan memuatnya, tapi pasti: ambil dari
> GitHub YSI-Includes). Letakkan 3 folder YSI itu di `include/` sebelum compile.

## 4. Edit kredensial DB di source

Buka `gamemodes/legacy/define.pwn`, ubah 4 baris ini:

```pawn
#define DATABASE_ADDRESS "localhost"   // biarkan (DB di VPS yang sama)
#define DATABASE_USERNAME "revitali"   // = user di DB-setup.sql
#define DATABASE_PASSWORD "GANTI_PASSWORD_KUAT"  // = password di DB-setup.sql
#define DATABASE_NAME "revitali_rp"    // biarkan
```

## 5. Compile gamemode

File source di repo ber-ekstensi `.pwn` (padahal isinya source `.pw`). Di Windows:

1. Copy folder repo ke VPS, misal `C:\build\RVRP\`
2. Rename semua file `.pwn` di `gamemodes/` → `.pw` (gunakan PowerShell:
   ```powershell
   Get-ChildItem -Path gamemodes -Recurse -Filter *.pwn | Rename-Item -NewName { $_.Name -replace '\.pwn$','.pw' }
   ```
3. Dari folder `gamemodes/` jalankan:
   ```
   packr.exe -oRVRP.pwn RVRP.pw
   ```
   (include YSI & legacy sudah di-resolve via path relatif, compile dari folder
   `gamemodes` supaya `#include "legacy\..."` ketemu.)
4. **0 errors** = sukses. File `gamemodes/RVRP.pwn` (hasil compile) siap di-deploy.

## 6. Struktur folder server (di VPS)

```
C:\SA-MP\
├── samp037sv.exe
├── samp03sv.ini          ← dari deploy\
├── gamemodes.txt         ← dari deploy\
├── gamemodes\
│   └── RVRP.pwn          ← hasil compile
├── plugins\
│   ├── mysql.dll
│   ├── sscanf.dll
│   ├── streamer.dll
│   ├── bcrypt.dll
│   ├── pawnmem.dll
│   └── plugins.ini       ← dari deploy\
├── filterscripts\
└── scriptfiles\
    └── Logs\
```

## 7. Firewall & jalankan

1. Windows Firewall → **allow UDP 7777** (New Rule → Port → UDP → 7777 → Allow).
   Kalau provider punya panel firewall, buka juga di sana.
2. Jalankan `samp037sv.exe` → pantau console:
   - `Loaded plugin: mysql.dll` (dll lain juga muncul)
   - `[DEALER] Loaded X dealership from database`
   - `Server initialized` / `Gamemode RVRP loaded`
3. Kalau muncul `Connection refused` / DB error → cek user+password di
   `define.pwn` dan apakah MySQL-nya nyala.

## 8. Auto-start saat VPS boot (biar gak mati pas reboot)

1. Download **NSSM**: https://nssm.cc/download
2. `nssm install SAVPS` → Path: `C:\SA-MP\samp037sv.exe` → Start directory: `C:\SA-MP`
3. Tab "Service" → Startup task: **Restart on fail**, interval 5 detik
4. `nssm start SAVPS` → selesai. Cek di `services.msc`.

## 9. Test

1. Client SA-MP versi **sama persis** dengan server (0.3.7 atau 0.3DL).
2. Add server: IP VPS + port 7777 → join.
3. Bikin UCP + character (UCP = password login, bcrypt).
4. Cek fitur: `/dealer`, `/veh`, `/house`, admin command (`/editdealer 0 spawn`).
5. Restart server → pastikan data persist (dealer/vehicle tetap ada).

## 10. Backup (rutin)

```
mysqldump -u revitali -p revitali_rp > backup_$(date +%F).sql
```
Jadwalkan via Task Scheduler harian + simpan ke drive lain/OneDrive.
