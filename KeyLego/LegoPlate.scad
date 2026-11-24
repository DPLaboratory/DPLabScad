/*
 *  LegoPlate.scad
 *  ------------------------------------------------------------------
 *  Piastra per tastiera compatibile LEGO.
 *
 *  Legge il layout della tastiera da keyboard_layout.scad (generato a
 *  partire dal JSON esportato da https://editor.keyboard-tools.xyz con
 *  layout_to_scad.ps1 - la build di OpenSCAD in uso non ha la funzione
 *  import() per i JSON) e genera una baseplate LEGO (usa la libreria
 *  LEGO.scad di Christopher Finke, vendorsa in questo progetto - MIT).
 *
 *  La piastra ha:
 *   - SOPRA: tasselli LEGO (pitch 8 mm) solo sull'anello di bordo, per
 *     agganciare pareti e altri elementi; la zona tastiera resta pulita
 *     per non disturbare l'inserimento di switch e tasti;
 *   - SOTTO: attacco femmina (fondo aperto "open bottom" con pareti e
 *     spline, niente perni interni) = i mattoncini si agganciano anche
 *     da sotto, e gli switch passano liberamente attraverso le aperture;
 *   - aperture per i tasti: fori da 14 mm per switch MX, vani completi
 *     per ogni tasto, oppure piastra piena senza fori.
 *
 *  Geometria di ogni tasto: [x, y, w, h] in unita' (1u), generata da
 *  layout_to_scad.ps1 a partire dal JSON KLE: stringhe = tasti 1x1,
 *  {"w":n} / {"h":n} / {"x":n} = dimensioni e sfasamenti (le proprieta'
 *  si applicano al tasto che le segue, es. {"w":2},"0\nIns").
 *
 *  Coordinate: la piastra occupa [0..L] x [0..W], z=0 sotto.
 *  La riga 0 del layout e' sul retro della piastra (y alto).
 *  ------------------------------------------------------------------
 */

use <LEGO.scad>

// Dati del layout: generare con  powershell -File .\layout_to_scad.ps1
include <keyboard_layout.scad>

/* [Layout tastiera] */
// Dimensione di 1u (un tasto standard) in mm
unit = 19.05;

/* [Piastra] */
// Anello di tasselli attorno alla zona tastiera (in passi da 8 mm)
margin_studs = 1; // [0:1:5]
// Spessore piastra in mm (min 3.2 = spessore piastra LEGO; sotto: attacco femmina)
plate_th = 3.2; // [3.2:0.1:9.6]
// Apertura per i tasti
opening = "switch"; // [switch:Foro switch MX, keywell:Vano completo del tasto, none:Piastra piena senza fori]
// Lato del foro per lo switch (14.0 nominal + gioco)
switch_opening = 14.1;
// Cornice perimetrale di ogni tasto, solo per keywell, in mm
key_frame = 1.2;

/* [LEGO] */
// Riscala solo i tasselli per compensare la stampante (1.05 = +5%)
stud_rescale = 1.00; // [0.90:0.005:1.20]
// Anteprima trasparente dei tasti (visibile solo in F5)
show_layout_preview = true;
// Aggiunge mattoncini di esempio sopra (pareti) e sotto la piastra
show_example_walls = false;

/* [Nascosto] */
stud_pitch = 8;   // passo dei tasselli LEGO
wall_play  = 0.1; // gioco fra mattoncini adiacenti (come in LEGO.scad)
stud_d     = 4.8; // diametro nominale tassello
stud_h     = 1.8; // altezza tassello
brick_unit_th  = 9.6; // altezza di 1 mattoncino LEGO

// ------------------------------------------------------------------
// Dati del layout
// ------------------------------------------------------------------

// layout_keys: lista [x, y, w, h] in unita' per ogni tasto (da keyboard_layout.scad)
keys = layout_keys;

assert(is_list(keys) && len(keys) > 0, "layout_keys vuoto: rigenera keyboard_layout.scad con layout_to_scad.ps1");

// Estensione del layout in unita'
total_u = [ max([for (k = keys) k[0] + k[2]]),
            max([for (k = keys) k[1] + k[3]]) ];

// Estensione della zona tastiera in mm
area = [ total_u[0] * unit, total_u[1] * unit ];

// Piastra in tasselli: zona tastiera + anello di margine
studs = [ ceil((area[0] + 2 * margin_studs * stud_pitch) / stud_pitch),
          ceil((area[1] + 2 * margin_studs * stud_pitch) / stud_pitch) ];

// Dimensioni reali della piastra (le stesse di LEGO.scad: length - 2*wall_play)
plate = [ studs[0] * stud_pitch - 2 * wall_play,
          studs[1] * stud_pitch - 2 * wall_play ];

// Centro della zona tastiera dentro la piastra
origin = [ (plate[0] - area[0]) / 2, (plate[1] - area[1]) / 2 ];

// Rettangoli dei tasti in coordinate piastra [x, y, w, h],
// con y misurata dal bordo frontale (riga 0 del layout = retro, y alto)
key_rects = [ for (k = keys)
    [ origin[0] + k[0] * unit,
      origin[1] + (total_u[1] - (k[1] + k[3])) * unit,
      k[2] * unit,
      k[3] * unit ] ];

// Rettangoli delle aperture
function opening_rect(r) =
    opening == "switch"
        ? [ r[0] + (r[2] - switch_opening) / 2,
            r[1] + (r[3] - switch_opening) / 2,
            switch_opening, switch_opening ]
        : [ r[0] + key_frame, r[1] + key_frame,
            r[2] - 2 * key_frame, r[3] - 2 * key_frame ];

openings = opening == "none" ? [] : [ for (r = key_rects) opening_rect(r) ];

// ------------------------------------------------------------------
// Matrice dei tasselli: presenti SOLO sull'anello di bordo; dentro la
// zona tastiera nessun tassello, per non disturbare switch e tasti.
// (LEGO.scad: "*" = tassello presente, "." = tassello omesso)
//
// Attenzione: LEGO.scad disegna SEMPRE il lato lungo del block() lungo X
// (width e length vengono scambiati internamente): se studs[1] > studs[0]
// la piastra va ruotata di 90 gradi, e la matrice costruita nelle
// coordinate ruotate (con x specchiata).
// ------------------------------------------------------------------

plate_rot      = studs[0] >= studs[1] ? 0 : 90;
matrix_columns = plate_rot == 0 ? studs[0] : studs[1];
matrix_rows    = plate_rot == 0 ? studs[1] : studs[0];

keepout = stud_d * stud_rescale / 2 + 0.4;

// Zona tastiera in coordinate piastra
key_area = [ origin[0], origin[1], area[0], area[1] ];

function in_rect(p, r, pad = 0) =
    p[0] > r[0] - pad && p[0] < r[0] + r[2] + pad &&
    p[1] > r[1] - pad && p[1] < r[1] + r[3] + pad;

function stud_center(i) = -wall_play + stud_d * stud_rescale / 2 + i * stud_pitch;

// Coordinate piastra del tassello (i, j) della matrice disegnata
// (i = colonna lungo il lato lungo disegnato, j = riga)
function matrix_point(i, j) =
    plate_rot == 0 ? [ stud_center(i), stud_center(j) ]
                   : [ plate[0] - stud_center(j), stud_center(i) ];

// Tassello omesso se cade nella zona tastiera oppure, con margini
// piccolissimi, se un'apertura lo sfiora.
function excluded(p) =
    in_rect(p, key_area, 0.2) ||
    [ for (o = openings) if (in_rect(p, o, keepout)) 1 ] != [];

stud_matrix = chr([ for (j = [0 : matrix_rows - 1], i = [0 : matrix_columns - 1])
                      excluded(matrix_point(i, j)) ? 46 : 42 ]);

// ------------------------------------------------------------------
// Moduli
// ------------------------------------------------------------------

// Piastra = mattoncino LEGO a fondo aperto (attacco femmina sotto):
// pareti esterne con spline, nessun perno interno (gli switch passano
// attraverso le aperture fino sotto la piastra), tasselli solo al bordo.
module lego_plate() {
    translate([ plate[0] / 2, plate[1] / 2, 0 ])
        rotate([0, 0, plate_rot])
            block(
                width  = min(studs[0], studs[1]),
                length = max(studs[0], studs[1]),
                height = plate_th / brick_unit_th,
                type   = "brick",
                block_bottom_type = "open",
                with_posts = false,
                stud_rescale        = stud_rescale,
                stud_matrix_string  = stud_matrix,
                stud_matrix_columns = matrix_columns
            );
}

// Fori dei tasti: attraversano piastra ed eventuali tasselli residui
module key_openings() {
    for (o = openings)
        translate([ o[0], o[1], -1 ])
            cube([ o[2], o[3], plate_th + stud_h + 2 ]);
}

// Anteprima (solo F5) dei tasti al loro posto, sotto forma di box fantasma
module key_previews() {
    for (r = key_rects)
        translate([ r[0], r[1], plate_th + stud_h ])
            %cube([ r[2], r[3], unit * 0.5 ]);
}

// Esempio di pareti a mattoncini: si agganciano ai tasselli del bordo.
// I block() di LEGO.scad sono centrati su XY: per posizionare l'angolo di
// un mattoncino su (cx, cy) in coordinate piastra serve translate di
// (+meta' della SUA lunghezza, +meta' della SUA larghezza).
module brick_at(width, length, cx, cy, z, rot = 0) {
    // LEGO.scad disegna sempre il lato lungo del mattoncino lungo X
    // (width/length vengono normalizzati): con rot=90 il mattoncino corre
    // lungo Y. (width, length) = dimensioni logiche del mattoncino.
    oL = max(width, length) * stud_pitch - 2 * wall_play;
    oW = min(width, length) * stud_pitch - 2 * wall_play;
    translate(rot == 0 ? [ cx + oL / 2, cy + oW / 2, z ]
                       : [ cx + oW / 2, cy + oL / 2, z ])
        rotate([0, 0, rot])
            block(width = width, length = length, height = 1, stud_rescale = stud_rescale);
}

module example_walls() {
    z = plate_th + stud_h; // i mattoncini poggiano sopra i tasselli
    // Parete frontale (2 tasselli di profondita', righe 0-1)
    brick_at(2, studs[0], 0, 0, z);
    // Parete posteriore (ultime 2 righe)
    brick_at(2, studs[0], 0, stud_pitch * (studs[1] - 2), z);
    // Parete sinistra (righe 2..penultima-1)
    brick_at(1, studs[1] - 4, 0, 2 * stud_pitch, z, rot = 90);
    // Parete destra
    brick_at(1, studs[1] - 4, stud_pitch * (studs[0] - 1), 2 * stud_pitch, z, rot = 90);
    // Mattoncino agganciato SOTTO la piastra (attacco femmina):
    // il suo top entra nella cava del fondo aperto, base a z = -plate_th.
    brick_at(2, studs[0], 0, 0, -plate_th);
}

// ------------------------------------------------------------------
// Modello
// ------------------------------------------------------------------

echo(str("Layout: ", len(keys), " tasti, ", total_u[0], "u x ", total_u[1], "u (",
         area[0], " x ", area[1], " mm)"));
echo(str("Piastra: ", studs[0], "x", studs[1], " tasselli (",
         plate[0], " x ", plate[1], " x ", plate_th, " mm)"));

difference() {
    lego_plate();
    key_openings();
}

if ($preview && show_layout_preview) key_previews();
if (show_example_walls) example_walls();
