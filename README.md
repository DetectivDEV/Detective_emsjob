# 🚑 Detective EMS Job

**detective_emsjob** — Advanced EMS / ambulance job for FiveM with a fully integrated death and medical system.

Originally based on the excellent [Arius Ambulance Job](https://github.com/Arius-Scripts/ars_ambulancejob) by **Arius Scripts**, redesigned and expanded with additional improvements and framework support.

---

## ✨ Features

- 🩺 Complete EMS & ambulance job system
- ☠️ Advanced death & injury mechanics
- 🚑 NPC paramedic treatment
- 🛏️ Stretchers & medical bag support
- 📢 Distress signal system
- 💉 Revive & heal system
- 🏥 Fully configurable hospitals
- 👨‍⚕️ EMS duty & staff management
- 🧰 Multi-framework support
- 📦 Multi-inventory compatibility
- 🎯 Optional target system support
- ⚡ Optimized and lightweight

---

## 🧩 Supported Frameworks

- ESX
- QBCore
- Qbox (`qbx_core`)

---

## 📦 Dependencies

### Required
- ox_lib
- oxmysql *(required for ESX death persistence)*

### Inventory Support
- ox_inventory
- qb-inventory

Default:
```lua
Config.Inventory = 'auto'
```

### Optional Target Systems
- ox_target
- qb-target

Used only if:
```lua
Config.UseTarget = true
```

Default interaction method uses:
- **[E] key**
- ox_lib text UI

---

## 📥 Installation

### 1. Rename Resource Folder

Make sure not to change the file name. It will be always the same.
```bash
detective_emsjob
```

---

### 2. Add Resource to `server.cfg`

```cfg
ensure detective_emsjob
```

---

### 3. Install Inventory Items

Inside:

```bash
!INSTALLATION/
```

Choose the correct file for your inventory:

- **ox_inventory** → `items_ox.lua`
- **qb-inventory** → `items_qb.lua`

---

### 4. Configure the Script

Edit:

```bash
config.lua
```

Configure:
- EMS jobs
- Hospital locations
- Death settings
- Inventory system
- Target system
- Revive settings
- NPC medic settings

---

## ⚙️ Example Config

```lua
Config.EmsJobs = {
    ambulance = true
}

Config.Inventory = 'auto'
Config.UseTarget = false
```

---

## 🏥 Hospital Features

Each hospital supports configurable:

- Zones
- Stashes
- Shops
- Garage
- Boss menu
- Clothing rooms
- Respawn locations

---

## 🛠️ Commands

| Command | Description |
|---|---|
| `/revive` | Revive player |
| `/heal` | Heal player |
| `/reviveall` | Revive all players |
| `/emsduty` | Toggle EMS duty |

---

## 📁 File Structure

```bash
detective_emsjob/
│
├── client/
├── server/
├── shared/
├── !INSTALLATION/
├── config.lua
├── fxmanifest.lua
└── README.md
```

---

## ❤️ Credits

| Role | Credits |
|---|---|

| Redesign & Improvements | Detective |
| Additional Contributions | SWGAURKO |
```| Original Script | Arius Scripts |```

---

## 📜 Disclaimer

This project is based on **Arius Ambulance Job**.

This repository is a redesign/fork and is **not officially affiliated with Arius Scripts** unless explicitly stated by the original author.

---

## ⭐ Support

If you encounter issues or have suggestions:

- Open a GitHub issue
- Submit a pull request
- Contact the developer/community support server
