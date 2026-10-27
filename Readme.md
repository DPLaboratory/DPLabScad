# DPLabScad

Raccolta di modelli parametrici in **OpenSCAD** (progetto DPLab).

## Contenuto

| Cartella | Modello | Descrizione |
|---|---|---|
| [`KeyCaps/`](KeyCaps) | Keycap low-profile Cherry MX | Keycap stile KEA compatibile Cherry MX (passo 19.05 mm), generabile singolarmente o come intero set |
| [`KickStand/`](KickStand) | Kickstand con cerniera print-in-place | Supporto da schiena per smartphone con cerniera stampata in un'unica stampa, senza supporti |

## KeyCaps — Keycap low-profile Cherry MX

**File:** `KeyCaps/Lowprofile/DPL_keycap_mx_low_profile.scad`
STL pronto: `KeyCaps/STL/DPL_keycap_Flat_low_profile_x12.stl`

Keycap compatibile con switch Cherry MX (stem Ø 5.6 mm con croce), altezza totale 5 mm, senza labbro. Le legende possono essere a rilievo con sommità piatta (unico elemento colorato) o incassate (engraved).

Caratteristiche principali:

- **Parametri chiave**: `pitch`, `gap`, `key_u` (larghezza in unità), `cap_h`, `wall`, `corner_r`.
- **Bordo superiore** selezionabile: smusso a 45° (`edge_style = "chamfer"`) oppure raccordo (`"round"`).
- **Dish**: cavità circolare superiore configurabile (diametro/profondità, `0` = superficie piatta).
- **Testo**: font, dimensioni (con auto-fit della legenda), rotazione, offset, modalità `none`/`flat`/`engraved`; legende doppie separate da `|` (es. `"!|1"`).
- **Modalità di costruzione** (`build_mode`):
  - `"single"` — un solo keycap (`key_text`, `key_u`);
  - `"set"` — intero set a partire dall'array `keys` (numeri, lettere, tasti funzione, larghezze 1u/1.25u/1.5u, ecc.), affiancato a griglia sul piatto (`set_cols`).
- **Ponticelli** (`link_mode`: `none`/`rows`/`grid`): sottili bridge a livello del piatto tra gli stem dei keycap del set per aumentare l'aderenza al primo strato; le croci degli stem restano libere e i ponticelli si tagliano via dopo la stampa.

## KickStand — cerniera print-in-place

**File:** `KickStand/kickstand_hinge_print_in_place.scad`

Kickstand parametrico con cerniera ad asse verticale (H = 12 mm) che si stampa in piedi, senza supporti — ispirato a *MakerWorld #1607317* e ricostruito dall'analisi di mesh STL.

Funzionamento:

- Il braccio ha una testa cilindrica con due perni conici (sopra e sotto) che entrano in sedi coniche nei "tappi" della piastra; gioco radiale 0.3 mm.
- Il braccio viene stampato aperto di ~4.3° (`print_angle`) per evitare che i pezzi si saldino; da chiuso ruota fino ad appoggiarsi alla piastra.
- Blocco a linguetta trapezoidale + tasca sulla piastra; dentini a gradino per appoggiare il telefono.
- Smusso a gradini su primo/ultimo strato (anti-elephant-foot) via `chamfered_extrude()`.
- **`part`**: `"both"` (piastra + braccio), `"plate"` o `"arm"`.

Tutte le quote principali sono esposte come parametri modulabili (sezioni `[Piastra]`, `[Cerniera]`, `[Braccio]`, `[Dentini di appoggio]`, `[Blocco linguetta/tasca]`).

## Utilizzo

1. Aprire il file `.scad` desiderato in [OpenSCAD](https://openscad.org/) (le versioni recenti gestiscono correttamente `assert`, `hull()` su 2D e `rotate_extrude()`).
2. Regolare i parametri in cima al file.
3. `F6` per il rendering completo, poi esportare in STL.
4. Usare l'anteprima (`F5`) per verificare rapidamente parametri e colori prima del render completo.

## Note

- Tutte le quote sono in **millimetri**.
- I commenti nel codice sono in italiano; i parametri critici hanno note sui valori di sicurezza (es. spessore tetto vs testo incassato, `link_h` vs pareti).
