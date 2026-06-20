# Heat-Aware Conky Cockpit — Drop-In Config

Single merged config with heat-reactive color overlay on the full grid layout.

## Structure
- SYSTEM header (2-column, 4 rows)
- CPU (btop-style lanes, heat-colored bars, RAM strip)
- GPU0 + GPU1 (thermal instrument panels, temp-colored headers)
- NETWORK strip
- DISK (pressure-colored usage bands)

## Heat Bands
| Band | Range | Color |
|------|-------|-------|
| Cool | < 60°C | green (color3) |
| Warm | 60–75°C | yellow (color2) |
| Hot  | > 75°C | red (color1) |

CPU core bars: < 50% green, 50–80% yellow, > 80% red.
Disk pressure: < 70% green, 70–90% yellow, > 90% red.

## Key Design
- Layout is fixed (no jitter, no block shifting)
- Only color/state changes dynamically
- CPU temp → CPU section color
- GPU temp → per-GPU panel color
- CPU load → per-core bar color
- Disk usage → urgency color

## Three-Layer Model
| Layer | Style |
|-------|-------|
| CPU | btop-style behavioral lanes |
| GPU | thermal instrument panels |
| DISK | pressure-based storage strip |
