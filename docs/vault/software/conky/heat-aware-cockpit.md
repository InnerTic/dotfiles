# Heat-Aware Conky Cockpit

Thermal-reactive UI overlay for the system telemetry panel.

## Core Concept

Keep the existing grid layout unchanged. Add a dynamic color layer that responds to temperature and load — the geometry stays stable, the *mood* shifts.

## Structure

- SYSTEM header (2-column, 4 rows)
- CPU (btop-style lanes, heat-colored bars, RAM strip)
- GPU0 + GPU1 (thermal instrument panels, temp-colored headers)
- NETWORK strip
- DISK (pressure-colored usage bands)

## Three-Layer Model

| Layer | Style |
|-------|-------|
| CPU | btop-style behavioral lanes |
| GPU | thermal instrument panels |
| DISK | pressure-based storage strip |

## Heat Bands

| Band | Temp Range | Color | Conky Color |
|------|-----------|-------|-------------|
| Cool | < 60°C | Green | `${color3}` |
| Warm | 60–75°C | Yellow | `${color2}` |
| Hot  | > 75°C | Red | `${color1}` |

CPU core bars: < 50% green, 50–80% yellow, > 80% red.
Disk pressure: < 70% green, 70–90% yellow, > 90% red.

## Key Design

- Layout is fixed (no jitter, no block shifting)
- Only color/state changes dynamically
- CPU temp → CPU section color
- GPU temp → per-GPU panel color
- CPU load → per-core bar color
- Disk usage → urgency color

## Thermal Queries

```conky
${execi 5 sensors | grep -m1 'Tctl' | awk '{print $2}' | sed 's/+//;s/°C//'}
```

```bash
nvidia-smi --id=N --query-gpu=temperature.gpu --format=csv,noheader
```

## Color State Implementation

```conky
${if_match ${execi 5 sensors | grep -m1 'Tctl' | awk '{print $2}' | sed 's/+//;s/°C//'} < 60}
${color3}
${else}${if_match ... < 75}
${color2}
${else}
${color1}
${endif}${endif}
```

## Load-Reactive Bars

```conky
${if_match ${cpu cpu0} < 50}${color3}${else}${if_match ${cpu cpu0} < 80}${color2}${else}${color1}${endif}${endif}${cpubar cpu0 6,55}${color}
```

MEM and SWAP bars follow same pattern with `${memperc}` and `${swapperc}`.

## Storage Pressure

Thresholds on `${fs_used_perc /}`: < 70% calm, 70–90% warning, > 90% critical.

## Network Activity Glow

```conky
${if_match ${downspeedf eth0} > 5000}${color2}${else}${color3}${endif}
```

## Result

- **Static structure**: CPU left, GPU right, DISK bottom, NET strip — unchanged
- **Dynamic layer**: color follows system state
- **Cockpit feel**: stable geometry + semantic emphasis = instrumentation panel
