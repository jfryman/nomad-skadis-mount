# Printing

Related: [geometry.md](geometry.md), [../skadis/summary.md](../skadis/summary.md).

## Reference print (Voron 2.4R2 300)
The slicer project is tracked at `print/nomad-skadis-mount-voron.3mf` (OrcaSlicer 2.4.2; checked to contain no print-host keys or local paths).
It was sliced from the `make` STL, re-oriented in the slicer.

| Setting | Value |
|---|---|
| Printer profile | Voron 2.4 300 0.4 nozzle - Bumblebee |
| Process | 0.20mm Standard @Voron (0.2mm layers, 0.2mm first layer) |
| Filament | Generic PLA - Stealthburner, 220°C, bed 55°C (High Temp Plate) |
| Walls | 3 loops, Arachne, aligned seam |
| Top / bottom | 4 / 3 layers, monotonic |
| Infill | **100% crosshatch** |
| Supports | on, normal(auto), 30° threshold, everywhere (not only from the build plate) |
| Brim | auto, 5mm |
| Speeds / accel | outer 120, inner 200, infill 200 mm/s; 5000 default / 3000 outer wall |

### Orientation used
The part sits **upright, floor down, as it hangs**, rotated 3° about the width axis to
cancel `recline`, so the floor's underside is flat on the bed. Footprint is ~200 × 76mm
and the height is ~49.6mm. The slicer transform maps model-frame `z_n` to `-z_n` of the bed.
In this pose the hook stems print horizontally and the legs hang below them, so the
legs need supports. 100% infill makes up for stems that are loaded across layer lines.

```mermaid
flowchart LR
  STL["make: STL stood on button end"] --> O["Orca: lay floor-down,<br/>rotate 3° (undo recline)"]
  O --> S["supports for hook legs<br/>+ jack hole"] --> P[Voron 2.4 300, PLA 100%]
```

## Alternative orientations
- `print_orientation = true` (what `make` exports) stands the part on its button end:
  ```openscad
  translate([0, 0, -x_min]) rotate([0, -90, 0]) mount();
  ```
  The hook profiles lie in the layer plane (strongest hooks) and no supports are needed,
  but it is ~198mm tall on a 52 × 71mm footprint and needs a brim.
- Lying on its back (hooks up) needs no hook supports, but the stems are weakest that way.

## Fit tuning
- Too tight or loose in the cradle: adjust `clr` (default 0.75).
- Hooks stiff in the slots: reduce `hook_w` or `stem_len` in small steps.
