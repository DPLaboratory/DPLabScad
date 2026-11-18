# Custodia per tastiera meccanica con coperchio-stand per tablet

File sorgente: [`custodia_tastiera_stand.scad`](custodia_tastiera_stand.scad)
OpenSCAD standard, nessuna libreria esterna. Commenti nel codice in italiano.

---

## 1. Di cosa si tratta

Una custodia (vasca) che ospita una tastiera meccanica. Il coperchio **non ruota
su un perno fisso**: è vincolato da una **cerniera a quadrilatero articolato**
(four-bar linkage) presente su **entrambi i lati**, quindi quando si apre
**retrocede e si inclina contemporaneamente**. Aperto a 70° il coperchio diventa
uno **stand per tablet** (stile mini-iPad con tastiera); il bordo inferiore del
coperchio si appoggia sulla piastra del vano posteriore, che fa **finecorsa**
contro il peso del tablet.

```
CHIUSO                                APERTO (70°)
┌──────────────────────┐              base ──┐
│  coperchio (piastra) │                    ┌┼────── coperchio inclinato
│ ═════════════════════│                    ││  ▲      (tablet appoggiato)
│ tastiera │ vano cavi │                    ││ 70°
└──────────────────────┘                    └┴── bielle articolate ai lati
```

### Quadrilatero articolato (per lato)

| Braccio | Elemento |
|---|---|
| B1 – P1 | **biella1** (B1 = perno fisso nella parete della base) |
| B2 – P2 | **biella2** (B2 = perno fisso nella parete della base) |
| P1 – P2 | **coppia** = il coperchio con le orecchie incollate |

Livelli lungo Y, dall'interno verso l'esterno, separati dal gioco `g`:

```
parete base | orecchio | biella1 | biella2
```

I perni B1/B2 attraversano: parete + orecchio (zona libera) + biella;
i perni P1/P2 collegano orecchio e biella.

### Componenti stampati (7 pezzi)

1. **base** – vasca con vano tastiera frontale, vano posteriore per cavi e
   accessori (**apribile con portellino a incasso**), passaggio cavi nel
   tramezzo, fori ciechi per i perni, alloggi magneti opzionali.
2. **coperchio** – piastra con fermo e guide per il tablet, tasche per le
   orecchie. Si stampa a faccia posteriore sul letto.
3. **2 orecchie** – incollate nel coperchio (profilo = inviluppo di due cerchi
   sui perni P1/P2 + tenone) e **fissate con 2 viti/perni Ø3 passanti per
   ciascuna**: il foro attraversa piastra + tenone + corpo dell'orecchio
   (`usa_viti_orecchio`).
4. **2 biella1 + 2 biella2** – profilo a fessura con fori per i perni.

Non stampati: **4 perni da 3 mm** (B1, B2, P1, P2 per lato) — barre, filo
lisciato o filamento.

---

## 2. Cinematica e verifiche

La sintesi è a due posate ed è **interamente parametrica**:

- **Chiusa**: origine coperchio `Oc = [0, Ztop]`, angolo 0° (poggia sul bordo).
- **Aperta**: origine `Oo = [D_kb + open_dx, Ztop]`, angolo `ang_open` (70°);
  il bordo inferiore poggia sulla piastra posteriore (finecorsa).
- Ogni perno coperchio `lp_i` ha due posizioni; il perno fisso `B_i` giace
  sull'**asse del segmento** tra le due, alla quota `zb_i`.
- Lunghezze: `L1 = |P1c−B1|`, `L2 = |P2c−B2|`, `d12 = |P2c−P1c|`.
- Le pose intermedie derivano ruotando la biella1 e risolvendo
  l'**intersezione di due cerchi**; il ramo corretto è scelto in modo analitico
  (quello che nella posa chiusa restituisce esattamente la posa chiusa).

### Verifiche eseguite (Python/numpy prima della stesura) e ripetute a runtime

Ad ogni compilazione il file scrive in console (`echo`) i risultati su 21 pose
intermedie. Con i valori predefiniti:

```
SINTESI:  L1 = 73.050  L2 = 95.861  d12 = 60
PERNI FISSI:  B1 = [97.058, 14]   B2 = [180.526, 18]
VERIFICHE:  P2-biella1 = 9.9 (>=8) | B1-biella2 = 11.0 (>=8) |
            P1-biella2 = 23.0 (>=20) | B1-coperchio = 24 (>=15) |
            B2-coperchio = 20 (>=15) | B2-biella1 = 46.4
```

- movimento continuo da 0 a 1, nessun cambio di ramo (max passo 2.4·10⁻⁵ mm);
- il sottocoperchio non penetra mai i keycap (gioco ≥ 3 mm) né la piastra
  posteriore (contatto esattamente 0, mai negativo);
- il baricentro, vicino alla posa aperta, spinge **verso il finecorsa**
  (dz/dt < 0): la gravità fa appoggiare il coperchio, non lo apre oltre.

> **Dopo ogni modifica ai parametri della cerniera: ricompila e rileggi gli
> `echo`** (e riattiva l'animazione per controllare il moto).

---

## 3. Parametri principali (in testa al file)

| Gruppo | Parametri | Note |
|---|---|---|
| Tastiera | `kb_w, kb_d, kb_h, tol` | `tol` = gioco tra tastiera e pareti |
| Tablet | `tablet_w, tablet_h, tablet_t` | determinano fermo e guide |
| Spessori | `floor_t, wall_f, wall_s, rear_top, top_gap, t_lid, lip_t, guide_t, guide_l` | |
| Cerniera | `pin_d, link_t, ear_t, g, link_w, ear_r, ang_open, open_dx, lp1_u, lp2_u, piv_v, zb1, zb2` | la sintesi si ricalcola da sola |
| Vano posteriore | `vano_d` | profondità interna: se cresce allunga la base |
| Portellino | `porta_aperta, porta_l, porta_cornice, porta_w, porta_t, porta_lip, porta_gioco, porta_foro_l, porta_foro_d, porta_foro_dx, porta_x` | a incasso, a filo, con foro pollice |
| Fissaggio orecchie | `usa_viti_orecchio, vit_d, vit_gioco, vit_svaso, vit_svaso_d` | fori passanti viti/perni Ø3 tra coperchio e orecchie |
| Magneti | `usa_magneti, mag_d, mag_h, mag_p1, mag_p2` | 4×2 mm, 2 per lato |
| Vista | `mostra, animazione, t_manuale, camera_auto` | vedi sotto |

Granidezze derivate: `D_kb, Ztop, Lu, Wi, Wt, Wl` e i livelli Y
(`Yw0…Yl21`). Alcuni `assert` bloccano la compilazione con messaggio chiaro se
una combinazione di parametri non è coerente (es. `porta_t >= rear_top`).

---

## 4. Come visualizzare

Cambia la variabile `mostra` e premi **F5** (preview) o **F6** (render):

| `mostra` | Contenuto |
|---|---|
| `"assieme"` | tutto montato nella posa aperta (con perni e portellino) |
| `"stampa"` | pezzi disposti piatti sul piano di stampa |
| `"base"` / `"coperchio"` | singolo pezzo |
| `"orecchio"` / `"biella1"` / `"biella2"` / `"portellino"` | le 2 copie in assetto di stampa |

### Esportare gli STL da riga di comando

```bat
openscad -o base.stl        custodia_tastiera_stand.scad -D "mostra=\"base\""
openscad -o coperchio.stl   custodia_tastiera_stand.scad -D "mostra=\"coperchio\""
openscad -o orecchio.stl    custodia_tastiera_stand.scad -D "mostra=\"orecchio\""
openscad -o biella1.stl     custodia_tastiera_stand.scad -D "mostra=\"biella1\""
openscad -o biella2.stl     custodia_tastiera_stand.scad -D "mostra=\"biella2\""
openscad -o portellino.stl  custodia_tastiera_stand.scad -D "mostra=\"portellino\""
openscad -o assieme.stl     custodia_tastiera_stand.scad -D "mostra=\"assieme\""
```

In alternativa: F6 → *File → Export → Export as STL*.

---

## 5. Come creare l'animazione

Il file implementa un'animazione a **8 fasi** con raccordi *smoothstep*,
attivata dalla variabile `animazione` (usa la variabile speciale `$t` di
OpenSCAD):

| Fase | Contenuto |
|---|---|
| 1 | la tastiera (fantasma grigia) si posa nella base |
| 2 | le orecchie scorrono di lato nelle tasche del coperchio (sollevato) |
| 3 | il coperchio scende sulla base |
| 4 | inserimento biella1 di lato |
| 5 | inserimento biella2 di lato |
| 6 | inserimento dei perni dall'esterno |
| 7 | apertura: il coperchio diventa stand (0 → 1) |
| 8 | il tablet (fantasma blu trasparente) scorre fino al fermo |

In ogni fase una **didascalia 3D** è mostrata in basso nella vista (orientata
verso la camera) e stampata in console con `echo`.

### 5.1 Modalità

```scad
animazione = "tutto";      // tutte le 8 fasi in sequenza
animazione = "assembla";   // solo le fasi 1-6 (montaggio), resta chiuso
animazione = "apri";       // parti da tutto montato: fasi 7-8
animazione = "nessuna";    // statico (usa `mostra`)
```

Per congelare un istante preciso (utile per screenshot) senza far girare il
tempo:

```scad
t_manuale = 0.55;   // istante forzato 0..1; ha priorità su $t (0 = disattivo)
```

### 5.2 Avvio nell'interfaccia grafica (GUI)

1. Apri il file, imposta `animazione = "tutto"` e salva.
2. Menu **View → Animate**: compare la barra in basso con i campi
   *FPS*, *Steps* e il pulsante Play.
3. Imposta per esempio:
   - **FPS = 12** (frame al secondo);
   - **Steps = 96** → per `"tutto"`: 8 fasi × 12 step = ciclo completo fluido
     (72 per `"assembla"`, 24 per `"apri"`).
4. Premi **Play ▶**. Con **F5** (preview) vedi colori e trasparenze dei
   fantasmi; la modalita animate ha senso solo in preview.
5. La camera è già impostata dal file
   (`$vpr=[62,0,215]`, `$vpt=[100,0,70]`, `$vpd=1250`). Per orbitare liberamente
   col mouse durante l'animazione metti `camera_auto = false;`.

Puoi anche scrivere a mano un valore di `$t` nel campo a sinistra della barra
Animate per esaminare un singolo istante.

### 5.3 Creare un video (riga di comando + ffmpeg)

OpenSCAD CLI genera una PNG per ogni step di `$t` con `--animate`:

```bat
mkdir frames
openscad -o frames/frame.png --animate 12 --imgsize 1280,720 ^
         --camera 100,0,70,1250,62,0,215 ^
         custodia_tastiera_stand.scad
```

- `--animate 12` = 12 step per unità di `$t` (96 frame per il ciclo "tutto":
  OpenSCAD genera `frame0001.png`, `frame0002.png`, …);
- `--camera x,y,z,dist,rx,ry,rz` riproduce la camera del file;
- assicurati che nel file `animazione = "tutto"` e `t_manuale = 0`.

Assembla il video con **ffmpeg**:

```bat
ffmpeg -framerate 12 -i frames/frame%04d.png -pix_fmt yuv420p animazione.mp4
```

Per un video più fluido aumenta `--animate` (es. 24 → 192 frame) e
`-framerate` di conseguenza.

### 5.4 GIF già pronte nel progetto

Nel progetto sono incluse due GIF (cartella [`img/`](img/)) generate con la CLI
di OpenSCAD (2026.09.07,
`C:\Users\debora.presti\Software\OpenSCAD-2026.09.07-x86-64\openscad.exe`).

**Funzionamento — apertura 0→1 e tablet che scorre fino al fermo**
(fasi 7–8, `animazione = "apri"`, 48 frame @ 800×600):

![Apertura della cerniera a quadrilatero articolato e tablet che scorre fino al fermo](img/animazione_apertura.gif)

**Montaggio completo nelle otto fasi** — tastiera, orecchie, coperchio,
bielle, perni, apertura, tablet
(`animazione = "tutto"`, 96 frame @ 640×480):

![Montaggio completo nelle otto fasi](img/animazione_completa.gif)

**Solo montaggio** — le prime 6 fasi, si ferma a coperchio chiuso
(`animazione = "assembla"`, 72 frame @ 640×480):

![Assemblaggio: tastiera, orecchie, coperchio, bielle e perni](img/animazione_assemblaggio.gif)

| File | Contenuto | Frame |
|---|---|---|
| `img/animazione_apertura.gif` | fasi 7–8 (`animazione = "apri"`): apertura 0→1 e tablet al fermo | 48 @ 800×600 |
| `img/animazione_completa.gif` | tutte le 8 fasi (`animazione = "tutto"`): montaggio + apertura | 96 @ 640×480 |
| `img/animazione_assemblaggio.gif` | fasi 1–6 (`animazione = "assembla"`): solo montaggio, resta chiuso | 72 @ 640×480 |

> Le GIF si vedono in anteprima su GitHub/GitLab e in qualunque visualizzatore
> Markdown che supporti le immagini animate; si vedono anche in VS Code
> (Markdown Preview).

Procedura usata per rigenerarle (output in `img/`):

1. si crea una **copia temporanea** del `.scad` con `animazione` impostato
   (`"apri"` o `"tutto"`; così si evitano problemi di quoting di `-D` su
   PowerShell);
2. si renderizzano i frame:
   ```bat
   openscad.exe -o apri.png --imgsize=800,600 --animate 48 anim_apri.scad
   ```
   → produce `apri00000.png … apri00047.png`;
3. si assembla la GIF con PIL (loop infinito, ~17 fps, pausa finale sullo
   stato concluso) e la si salva in `img/`:
   ```python
   from PIL import Image
   files = sorted(glob.glob("apri0*.png"))
   imgs  = [Image.open(f).convert("RGB") for f in files]
   imgs[0].save("img/animazione_apertura.gif", save_all=True,
                append_images=imgs[1:], duration=[60]*len(imgs), loop=0,
                optimize=True)
   ```

Nota: la didascalia 3D è ancorata al bordo inferiore della vista tramite il
vettore "su dello schermo" della camera gimbal (`R(vpr)·[0,1,0]`); se cambi
`$vpd` o la camera, riaggiusta l'offset `215` in `didascalia()`.

### 5.5 Buone pratiche

- L'animazione è la **verifica visiva della cinematica**: dopo ogni modifica ai
  parametri della cerniera riattivala e guarda le fasi 7 (nessun salto, nessun
  contatto) e 8 (il tablet si ferma sul fermo).
- Se qualcosa "trema" o salta in preview, alza la finestra di OpenSCAD: la
  preview ricampiona la scena a ogni frame.
- Le `assert` del file proteggono comunque la compilazione: se un parametro
  rende il meccanismo incoerente, OpenSCAD si ferma con un messaggio.

---

## 6. Stampa e montaggio

- **Letto di stampa**: il coperchio misura **≈ 340 × 195 mm**: serve un piatto
  grande (o dividilo in due sezioni e giunale le piastre, ad esempio con
  rincalzo e cianoacrilato).
- **Materiale**: PETG o ABS consigliati per la base (rigidità + resistenza
  termica al sole); il coperchio-stand è meglio in PETG/ABS pieno.
- **Parametri suggeriti**: 0.2 mm di strato, 3 perimetrature, riempimento
  ≥ 25 % (gyroid o cubic) per base e coperchio; orecchie e bielle al 100 % o
  con 6 perimetrature (i perni lavorano a compressione sui fori).
- **Portellino**: si stampa piatto, lato grande sul letto, senza supporti.
- **Supporti**: non necessari in nessun pezzo (tutti i fori orizzontali sono
  passanti o ciechi dal lato esterno).
- **Montaggio**:
  1. incolla le orecchie nelle tasche del coperchio (il tenone entra nella
     tasca; cianoacrilato o epossidica),
  2. fissa ogni orecchio con **2 viti o perni Ø3 passanti** (`usa_viti_orecchio`):
     il foro esce sotto l'orecchio, quindi si può usare un perno incollato o
     una vite con dado (o autofilante in pressione nel foro Ø3.2),
  3. appoggia il coperchio chiuso sulla base: i fori di B1/B2 si allineano,
  4. inserisci le bielle di lato nelle rispettive fasce Y,
  5. spingi i **perni da 3 mm** dall'esterno (B1/B2 attraversano parete +
     orecchio + biella; P1/P2 orecchio + biella).

---

## 7. Struttura del file (per orientarsi)

```
PARAMETRI ................ tastiera, tablet, spessori, cerniera, vano,
                          portellino, magneti, vista/camera
GRANDEZZE DERIVATE ....... D_kb, Ztop, Lu, Wi, Wt, Wl, livelli Y, assert
CINEMATICA 2D (x, z) ..... rot2, ang_v, bialetta (sintesi), intersez_cerchi,
                          segno_ramo, posa(t), loc_cop + echo verifiche
MODULI ................... estrusa_y, base, portellino, coperchio_solido,
                          in_coperchio, profilo_orecchio (+ zona_libera_2d),
                          biella, perno_sxy/perni_in_posa, fantasmi
MODALITA' DI VISTA ....... assieme, piano_stampa, stampa singoli pezzi
ANIMAZIONE ............... sstep, fase(i), didascalie, didascalia 3D,
                          scena_animata
INVOCO ................... scelta per `mostra` / `animazione`
```

---

*Licenza: uso libero; cita l'autore se ridistribuisci il file.*
