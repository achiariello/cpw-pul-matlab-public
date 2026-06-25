# Example: gold CPS on GaAs

Questo esempio usa le routine del repository per il caso:

- due strisce d'oro larghe **20 um**
- alte **1 um** (spessore fisico riportato, non incluso nel modello chiuso Eq. 1-8)
- distanza tra i bordi interni **50 um** (quindi `2g = 50 um`, `g = 25 um`)
- substrato GaAs di spessore **1 um**

## Immagine della struttura

![Sezione CPS su GaAs](structure.svg)

## Permittività relativa del GaAs

Valore usato: **epsr = 12.9** (300 K, dielectric constant static).

Fonte:
- Ioffe Institute, *Basic Parameters of Gallium Arsenide (GaAs)*  
  https://www.ioffe.ru/SVA/NSM/Semicond/GaAs/basic.html

## Script MATLAB

Esegui:

```matlab
example_gaas_gold_cps
```

Lo script calcola:

- `Cpul` (capacità per unità di lunghezza)
- `Z0` (impedenza caratteristica)
- `Lpul` tramite:

```matlab
Lpul = Z0^2 * Cpul
```

## Risultato numerico atteso

Con i parametri sopra:

- `Cpul ≈ 1.062525e-11 F/m` (`10.625253 pF/m`)
- `Z0 ≈ 314.152540 Ohm`
- `Lpul ≈ 1.048626e-06 H/m` (`1048.625523 nH/m`)
