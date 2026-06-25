# CPS MATLAB routines (Eq. 6 and Eq. 8)

Questa cartella contiene routine MATLAB per linea CPS su substrato singolo:

- `cps_single_layer_params.m`: calcolo di capacità per unità di lunghezza `C` e impedenza caratteristica `Z` usando le equazioni (1), (5), (6), (7), (8).
- `verify_table1.m`: verifica numerica con i valori riportati in **Table 1** dell'articolo.
- `cps_rpul_matrix_skin.m`: calcolo della matrice `Rpul` (2x2) per skin effect a una data frequenza.

## Riferimento bibliografico

S. Gevorgian and H. Berg, **"Line Capacitance and Impedance of Coplanar-Strip Waveguides on Substrates with Multiple Dielectric Layers"**, EuMC 2001.

## Nota importante su MATLAB e integrali ellittici

Nel paper si usa il **modulo** `k` per `K(k)`, mentre in MATLAB:

- `ellipke(m)` usa il **parametro** `m = k^2`

Nelle routine, quindi, `K(k)` viene calcolato come `ellipke(k.^2)`.

## Pubblicazione delle routine

Le due routine sono pubblicate in questa cartella del repository GitHub per condivisione e riuso.
