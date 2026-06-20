# Heat-Aware Conky Cockpit

Thermal-reactive UI overlay for the system telemetry panel.

## Core Concept

Keep the existing grid layout unchanged. Add a dynamic color layer that responds to temperature and load — the geometry stays stable, the *mood* shifts.

## Thermal Model

### CPU Heat
```
${execi 5 sensors | grep -m1 'Tctl' | awk '{print $2}' | sed 's/+//;s/°C//'}
```

### GPU Heat
Per-GPU temperature via nvidia-smi:
```
nvidia-smi --id=N --query-gpu=temperature.gpu --format=csv,noheader
```

## Color States (3-band)

| Band | Temp Range | Color | Meaning |
|------|-----------|-------|---------|
| Cool | < 60°C | ${color3} (green) | Normal |
| Warm | 60–75°C | ${color2} (yellow) | Warning |
| Hot  | > 75°C | ${color1} (red) | Critical |

### Conky Implementation
```conky
${if_match ${execi 5 sensors | grep -m1 'Tctl' | awk '{print $2}' | sed 's/+//;s/°C//'} < 60}
${color3}
${else}${if_match ... < 75}
${color2}
${else}
${color1}
${endif}${endif}
```

Applied to: CPU header, GPU headers, section dividers.

## Load-Reactive Bars

CPU core bars change color based on utilization:
- < 50% → green
- 50–80% → yellow  
- > 80% → red

```
${if_match ${cpu cpu0} < 50}${color3}${else}${if_match ${cpu cpu0} < 80}${color2}${else}${color1}${endif}${endif}${cpubar cpu0 6,55}${color}
```

MEM and SWAP bars follow same pattern with `${memperc}` and `${swapperc}`.

## Storage Pressure (Disk)

Thresholds on `${fs_used_perc /}`:
- < 70% → calm
- 70–90% → warning
- > 90% → critical

## Network Activity Glow

Idle = calm color, active transfer = warm glow:
```
${if_match ${downspeedf eth0} > 5000}${color2}${else}${color3}${endif}
```

## Result

- **Static structure**: CPU left, GPU right, DISK bottom, NET strip — unchanged
- **Dynamic layer**: color follows system state — section headers, bars, and urgency all react
- **Cockpit feel**: stable geometry + semantic emphasis = instrumentation panel

## Next Directions

1. **Thermal zoning** — hot subsystems subtly dim/brighten
2. **Load-driven emphasis** — hot subsystem visually dominates without moving
3. **Real cockpit mode** — 3 colors only (OK/WARN/CRIT), no decorative variation
