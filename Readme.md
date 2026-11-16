# DPLabScad

Raccolta di modelli parametrici in **OpenSCAD** (progetto DPLab).

## Contenuto

| Cartella | Modello | Descrizione |
|---|---|---|
| [`KeyCaps/`](KeyCaps) | Keycap low-profile Cherry MX | Keycap stile KEA compatibile Cherry MX (passo 19.05 mm), generabile singolarmente o come intero set |
| [`KickStand/`](KickStand) | Kickstand con cerniera print-in-place | Supporto da schiena per smartphone con cerniera stampata in un'unica stampa, senza supporti |
| [`Appendiabiti conico/`](Appendiabiti%20conico) | Appendiabiti conico da parete | Appendiabiti a cono con vite nascosta e tappo frontale a scatto (stile Yconic) |
| [`Basi-modellismo/`](Basi-modellismo) | Basi rotonde per miniature | Basi parametriche con 6 superfici texturizzate (mattoni, ciottoli, sterrato, assi, lastre) e alloggio magnete |
| [`Label/`](Label) | Label bicolore | Etichette multicolore (2 parti/colori) per export 3MF: versione rettangolare e ornamentale |
| [`SD Mirco Holder Combined/`](SD%20Mirco%20Holder%20Combined) | Porta SD/microSD/USB | Organizer a griglia per schede SD, microSD e penne USB, con frontale testo o cilindrica |

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

## Appendiabiti conico — vite nascosta + tappo a scatto

**File:** `Appendiabiti conico/appendiabiti_conico.scad`

Appendiabiti da parete a forma di cono (cavo), stile Yconic: la vite rimane nascosta dentro il corpo e si accede dal fronte.

- **Corpo**: imbocco cilindrico lato parete (Ø `d_neck`) che si apre a cono verso il fronte (Ø `d_head`); piastrina posteriore forata con svasatura interna per la testa della vite.
- **Tappo**: disco frontale con gonna dotata di linguette elastiche (`n_slits` tagli) e dentino ("bead") a smusso 45° che scatta in una gola ricavata nel bordo interno del corpo.
- **Montaggio**: si avvita il corpo al muro, poi si preme il tappo.
- **`part`**: `"print"` (entrambi i pezzi in posizione di stampa), `"assembly"` (montato), `"body"`, `"cap"`, `"section"` (sezione per controllo).
- Stampa senza supporti: il corpo va a faccia frontale in basso (la gola non resta in sbalzo).

## Basi-modellismo — basi rotonde per miniature

**File:** `Basi-modellismo/basi_miniature.scad`

Basi rotonde parametriche per miniature da wargame/terrain, con superficie selezionabile:

- **Superfici** (`superficie`): `liscia`, `mattoni` (anche irregolari, con malta e sfalsatura), `ciottoli` (selciato irregolare su griglia disturbata), `sterrato` (sassolini sparsi con densità e dimensione casuali), `assi` (assi di legno con fessure, giunti di testa, dislivelli e venature), `lastre` (lastre di pietra generate con celle di Voronoi, fughe e smusso).
- **Parametri base**: `diametro`, `altezza`, smussi sopra/sotto, anello esterno `bordo_liscio` non texturizzato, alloggiamento magnete sotto la base (`diametro_magnete`).
- **Texture**: `profondita`, `angolo_texture` e `seed` (ogni valore genera una variante diversa della texture).
- Tutte le sezioni di parametri hanno `assert` di controllo sui limiti di sicurezza.

> Rendering: ciottoli e sterrato uniscono molte sfere, quindi con il motore CGAL il rendering finale (F6) può essere lento. In Preferenze → Funzionalità attiva Manifold, se la tua versione di OpenSCAD lo supporta, e diventa molto più rapido. Per lo sterrato puoi anche abbassare densita.

## Label — etichette bicolore per stampa multicolore

Cartella `Label/` con due varianti, entrambe divise in due parti/colori (`"base"` = piastra, `"detail"` = testo + bordi) pensate per la stampa 3D multicolore (export 3MF da `part = "all"`, oppure esportare le due parti separatamente e unirle nello slicer):

**`label_rettangolare.scad`** — rettangolo con angoli arrotondati, bordo superiore smussato, cornice a linea (`frame_dist`, `frame_w`) e testo centrato a filo con la superficie (modalità `inlay`, consigliata) o in rilievo. Testo multi-riga con auto-fit opzionale (`fit_text`).

**`label_ornamentale.scad`** — rettangolo con angoli concavi (`notch_r`), doppio bordo (linea sottile + linea spessa) e giglio decorativo opzionale in alto al centro (`giglio`, `show_ornament`). Stesse opzioni di testo e `inlay` della versione rettangolare.

I file `.json` nella cartella sono preset del Customizer (insiemi di parametri salvati).

## SD Mirco Holder Combined — organizer SD / microSD / USB

**File:** `SD Mirco Holder Combined/SD_MircoSD_USB_Holder_Combined.scad`

Scatola a griglia (`row` × `col`) con vani per schede SD, microSD e penne USB, con fori di estrazione ai lati.

- **Parametri**: `row`/`col` (dimensioni della griglia), `tol` (tolleranza di gioco globale).
- **Frontale** (`TYPE_FRONT`): `NONE`, `TEXT` (pannello con testo, es. `Text = "DEMO"`, `Font`) o `CYLINDER` (bordo cilindrico).

## Utilizzo

1. Aprire il file `.scad` desiderato in [OpenSCAD](https://openscad.org/) (le versioni recenti gestiscono correttamente `assert`, `hull()` su 2D e `rotate_extrude()`). Con OpenSCAD recente attivare il backend **Manifold** per rendering più veloci (vedi Basi-modellismo).
2. Regolare i parametri in cima al file (o usare i preset `.json` del Customizer dove presenti).
3. `F6` per il rendering completo, poi esportare in STL (o 3MF per i modelli multicolore).
4. Usare l'anteprima (`F5`) per verificare rapidamente parametri e colori prima del render completo.

## Note

- Tutte le quote sono in **millimetri**.
- I commenti nel codice sono in italiano; i parametri critici hanno note sui valori di sicurezza (es. spessore tetto vs testo incassato, `link_h` vs pareti).
