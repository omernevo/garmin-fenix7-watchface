# Garmin Fenix 7 Watchface - Custom Pro Digital

A custom Garmin Connect IQ watchface designed and optimized for the **Garmin Fenix 7** (260×260 MIP display) with multi-device support (Fenix 7S, Fenix 7X, Epix 2, Forerunner 955/965, Enduro 2).

---

## 📸 Design & Features Overview

Matches the reference watchface specifications:

- **Center Time Display**:
  - **Hours**: Large solid white block digits.
  - **Minutes**: Large outlined / hollow white digits with crisp contrast.
  - **Active Mode (Awake / High-Power)**: Small cyan seconds digits (`39`) at 3 o'clock.
  - **Rest Mode (Sleep / Low-Power)**: Cyan horizontal tick bar replacing the seconds at 3 o'clock, mirroring the 9 o'clock tick bar.
- **6 Perimeter Ring Data Fields & Cyan Ticks**:
  - `12:00 Top`: Wind speed & direction from Garmin / OWM (`13 NW`).
  - `~2:00 Top-Right`: Precipitation probability % and 1h rain volume (`100% 0mm`).
  - `~4:00 Bottom-Right`: Total steps in the calendar week starting Monday (`STEP 7.3k`).
  - `6:00 Bottom`: Date formatted as `DAY MM D` (`MON AUG 17`).
  - `~8:00 Bottom-Left`: Cycling distance (KM) in the calendar week starting Monday (`BIKE 9.0`).
  - `~10:00 Top-Left`: Time in Israel (`ISR 10:07` / `ISR 10:16` - UTC+3 DST / UTC+2).
  - **6 Cyan Accent Ticks**: Positioned at ~1:00, 3:00 (or seconds), 5:00, 7:00, 9:00, 11:00.
- **Upper Data Grid (Above Time)**:
  - **Center Top**: Current temperature from OpenWeatherMap (`18`).
  - **Left**: Elevation in meters (`132`) with mountain peak icon.
  - **Center**: Max/Min temperature from OWM (`21/17`) with weather icon.
  - **Right**: Next sun event (`20:31` sunset/sunrise) with sun horizon icon.
  - Vertical divider lines separating columns.
- **Lower Data Grid (Under Time)**:
  - **Left**: Weekly intensity minutes starting Monday (`35`) with runner icon underneath.
  - **Center**: Current Heart Rate (`61` / `63`) with ECG heart icon underneath.
  - **Right**: Total steps today (`7.3k`) with footsteps icon underneath.
  - **Bottom Under Heart Icon**: 7-Day Average Resting Heart Rate (`46`).
- **OpenWeatherMap Integration**:
  - Background service query to OpenWeatherMap API using key `767c5a6ab53c51d09cbc74d3adc63a3f`.
  - Configurable update interval and units in Garmin Connect Mobile settings.

---

## 🚀 How to Test & Provide Feedback

### Option 1: Instant Browser Simulator (Zero Setup Required)
Simply open [`preview.html`](file:///c:/GitProjects/GarminFenix7%20watchface/preview.html) in your browser:
1. Double-click `preview.html` in your file explorer or open it in Chrome/Edge/Firefox.
2. Features in the Simulator:
   - **Active vs Rest Mode Toggle**: Switch between High-Power (cyan seconds `39`) and Low-Power (cyan horizontal line).
   - **Presets**: Click **Photo 1 (09:07:39)**, **Photo 2 (09:16)**, or **Live Time** to test clock movement.
   - **Live OpenWeatherMap Test**: Click **Fetch Live** to run live API calls with your API key and see live weather update on the watch!
   - **Interactive Data Sliders**: Adjust heart rate, intensity minutes, steps, elevation, wind, Israel time offset, etc.

---

### Option 2: Garmin Connect IQ SDK & VS Code
To build and run in the official Garmin Connect IQ Simulator:
1. Open this folder in **VS Code**.
2. Install the official **Monkey C** extension (`garmin.monkey-c`).
3. Press `Ctrl + Shift + P` and select:
   - `Monkey C: Verify Installation`
   - `Monkey C: Build for Device` -> Choose `fenix7`.
   - `Monkey C: Run App` -> Starts the Fenix 7 Connect IQ simulator.
4. Sideload to your physical Fenix 7:
   - Export `.prg` binary using `Monkey C: Export Project`.
   - Connect watch via USB and copy `.prg` to the `GARMIN/APPS/` folder.

---

## 📁 Codebase Structure

```
.
├── manifest.xml                          # Connect IQ app manifest & target devices
├── monkey.jungle                         # Build config
├── preview.html                          # Interactive HTML5 Simulator & Tester
├── resources/
│   ├── drawables/
│   │   ├── drawables.xml
│   │   └── launcher_icon.png             # Launcher icon
│   ├── settings/
│   │   ├── properties.xml                # Persistent app properties
│   │   └── settings.xml                  # Garmin Connect Mobile settings schema
│   └── strings/
│       └── strings.xml                   # Localized strings
└── source/
    ├── Fenix7WatchFaceApp.mc             # App entry point & background event receiver
    ├── Fenix7WatchFaceView.mc            # Main watchface Direct-DC rendering engine
    ├── BackgroundServiceDelegate.mc      # OpenWeatherMap background API fetcher
    ├── ActivityHistoryHelper.mc          # Monday-start weekly steps, bike km, HR, RHR, ISR time
    ├── SunCalc.mc                        # Solar astronomical sunrise/sunset calculator
    ├── VectorIcons.mc                    # High-precision vector icon draw routines
    └── OutlinedFontRenderer.mc           # Solid hours + hollow outlined minutes renderer
```
