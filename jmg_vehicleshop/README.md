# ESX Vehicle Shop Script

Script toko kendaraan modern untuk ESX dengan sistem manajemen pemilik, sistem stok, dan UI yang indah.

## 🚗 Fitur Utama

- **Manajemen Pemilik**: Sistem kepemilikan toko (bukan berbasis job)
- **UI Modern**: Interface web yang indah dan responsif
- **Manajemen Stok**: Pelacakan stok kendaraan real-time
- **Analitik Penjualan**: Laporan penjualan dan statistik detail
- **Test Drive**: Memungkinkan pemain mencoba kendaraan sebelum membeli
- **Harga Kustom**: Pemilik toko dapat mengatur harga khusus
- **Multi-Kategori**: Kategori kendaraan yang terorganisir
- **Update Real-time**: Update stok dan penjualan secara langsung
- **Multi-bahasa**: Dukungan untuk berbagai bahasa (EN/ID)
- **Integrasi Database**: Integrasi database MySQL lengkap
- **Auto-Installation**: Sistem instalasi otomatis

## 📦 Instalasi

### Metode 1: Instalasi Otomatis (Direkomendasikan)

1. Extract folder `vehicleshop` ke direktori `resources` Anda
2. Tambahkan `ensure vehicleshop` ke `server.cfg` Anda
3. Restart server Anda
4. Script akan otomatis membuat tabel database dan data stok awal
5. Gunakan command `/setshopowner [playerId] PDM` untuk mengatur pemilik toko

### Metode 2: Instalasi Manual

1. Extract folder `vehicleshop` ke direktori `resources` Anda
2. Import file `vehicleshop.sql` ke database Anda
3. Tambahkan `ensure vehicleshop` ke `server.cfg` Anda
4. Konfigurasi script di `config.lua`
5. Restart server Anda

## 📋 Dependencies

- **ESX Framework** (Legacy atau Extended)
- **oxmysql** (untuk database)
- **Web browser** (untuk UI)

## ⚙️ Configuration

### Basic Setup
Edit file `config.lua` untuk menyesuaikan:

```lua
-- Lokasi shop
Config.Shops = {
    PDM = {
        Pos = {x = -56.727, y = -1096.612, z = 25.422},
        Heading = 25.0,
        -- ... konfigurasi lainnya
    }
}

-- Kendaraan yang tersedia
Config.Vehicles = {
    ['adder'] = {name = 'Adder', price = 1000000, category = 'super'},
    -- ... tambahkan kendaraan lainnya
}
```

### Advanced Configuration
```lua
-- General Settings
Config.DrawDistance = 10.0          -- Jarak render marker
Config.LicenseEnable = true         -- Enable driving license requirement
Config.LicensePrice = 5000          -- Harga driving license
```

## 👑 Owner Management

### Set Shop Owner (Admin Only)
```lua
/setshopowner [playerId] [shopName]
# Contoh: /setshopowner 1 PDM
```

### Remove Shop Owner (Admin Only)
```lua
/removeshopowner [shopName]
# Contoh: /removeshopowner PDM
```

### Transfer Ownership
Owner dapat transfer kepemilikan melalui Boss Menu di dalam game.

## 📦 Stock Management

### Add Stock (Admin Only)
```lua
/addvehiclestock [vehicle] [amount] [shopName]
# Contoh: /addvehiclestock adder 5 PDM
```

### Owner Stock Management
Owner dapat mengelola stok melalui Boss Menu:
- Add/Remove stock
- Set custom pricing
- View sales history

## 🎮 Usage Guide

### For Players
1. **Kunjungi Vehicle Shop** - Pergi ke marker biru di lokasi shop
2. **Browse Kendaraan** - Gunakan kategori dan search untuk mencari kendaraan
3. **Test Drive** - Coba kendaraan sebelum membeli (2 menit)
4. **Purchase** - Beli kendaraan dengan license plate custom

### For Shop Owners
1. **Access Boss Menu** - Pergi ke marker merah di area boss
2. **Manage Stock** - Tambah/kurangi stok kendaraan
3. **Set Prices** - Atur harga custom untuk kendaraan
4. **View Analytics** - Lihat riwayat penjualan dan statistik
5. **Transfer Ownership** - Transfer kepemilikan ke player lain

## 🎨 UI Features

### Shop Interface
- **Category Filter** - Filter berdasarkan kategori kendaraan
- **Search Function** - Cari kendaraan berdasarkan nama
- **Vehicle Cards** - Tampilan card yang informatif
- **Stock Indicator** - Indikator stok dengan warna
- **Money Display** - Tampilan uang player real-time

### Boss Interface
- **Stock Management** - Kelola stok dengan mudah
- **Sales History** - Riwayat penjualan lengkap
- **Settings Panel** - Pengaturan dan transfer ownership
- **Responsive Design** - Tampilan yang responsif

## 🗃️ Database Schema

### Tables
```sql
vehicleshop_owners     -- Data pemilik toko
vehicleshop_stock      -- Data stok kendaraan
vehicleshop_sales      -- Riwayat penjualan
```

### Views
```sql
v_vehicleshop_summary  -- Summary data toko
v_low_stock_alerts     -- Alert stok rendah
v_sales_analytics      -- Analitik penjualan
```

## 🔧 Customization

### Adding New Vehicles
```lua
-- Tambahkan ke Config.Vehicles di config.lua
['newvehicle'] = {
    name = 'New Vehicle Name',
    price = 50000,
    category = 'sports'
}
```

### Adding New Categories
```lua
-- Tambahkan ke Config.Categories
['newcategory'] = 'New Category Name'
```

### Custom Locations
```lua
-- Tambahkan shop baru ke Config.Shops
NewShop = {
    Pos = {x = 0.0, y = 0.0, z = 0.0},
    Heading = 0.0,
    ShowroomVehicles = {},
    SpawnPoint = {x = 0.0, y = 0.0, z = 0.0, h = 0.0},
    BossMenu = {x = 0.0, y = 0.0, z = 0.0}
}
```

## 🎯 Performance Tips

1. **Database Optimization**
   - Gunakan indexing yang sudah disediakan
   - Regular cleanup data sales lama
   - Monitor query performance

2. **Client Performance**
   - Adjust DrawDistance sesuai kebutuhan
   - Optimize showroom vehicle count
   - Use streaming untuk model loading

3. **Server Performance**
   - Cache vehicle data
   - Limit concurrent test drives
   - Implement rate limiting

## 🐛 Troubleshooting

### Common Issues

**UI tidak muncul:**
```lua
-- Pastikan NUI enabled di server.cfg
set sv_enableNUI 1
```

**Database error:**
```lua
-- Pastikan oxmysql running dan configured
-- Check connection string di server.cfg
```

**Vehicle tidak spawn:**
```lua
-- Check vehicle model name di config
-- Pastikan vehicle ada di game files
```

### Debug Commands
```lua
-- Check owner status
/setshopowner [id] PDM

-- Add test stock
/addvehiclestock adder 1 PDM

-- Check database
SELECT * FROM vehicleshop_owners;
```

## 📝 Changelog

### Version 1.0.0
- Initial release
- Owner management system
- Modern UI implementation
- Stock management
- Sales analytics
- Test drive feature
- Database optimization

## 🤝 Support

Jika Anda mengalami masalah atau membutuhkan bantuan:

1. **Check Documentation** - Baca dokumentasi ini dengan teliti
2. **Check Logs** - Periksa console logs untuk error
3. **Database Check** - Pastikan database setup dengan benar
4. **Dependencies** - Pastikan semua dependencies terinstall

## 📄 License

Script ini dibuat untuk komunitas FiveM Indonesia. Silakan gunakan dan modifikasi sesuai kebutuhan.

## 🙏 Credits

- **ESX Framework** - Core framework
- **FiveM Community** - Resources dan support
- **oxmysql** - Database connector

---

**Selamat menggunakan Vehicle Shop Script! 🚗💨**

*Dibuat dengan ❤️ untuk komunitas FiveM Indonesia*