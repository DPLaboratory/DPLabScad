/*
 *  LegoPlate.scad
 *  ------------------------------------------------------------------
 *  Piastra per tastiera compatibile LEGO.
 *
 *  Legge il layout della tastiera da keyboard_layout.scad (generato a
 *  partire dal JSON esportato da https://editor.keyboard-tools.xyz con
 *  layout_to_scad.ps1 - la build di OpenSCAD in uso non ha la funzione
 *  import() per i JSON) e genera una piastra LEGO (usa la libreria
 *  LEGO.scad di Christopher Finke, vendorsa in questo progetto - MIT).
 *
 *  La piastra e' composta da:
 *   - un ANELLO di bordo di mattoncini LEGO (spessore plate_th):
 *     SOPRA tasselli solo sul bordo per pareti e altri elementi,
 *     SOTTO attacco femmina completo (fondo aperto con spline e
 *     pin/perni, come il fondo di un mattoncino originale);
 *   - il CAMPO TASTI centrale: mattoncino a fondo aperto SENZA tasselli
 *     e SENZA perni interni = superficie pulita sopra per non disturbare
 *     switch e tasti, attacco femmina sotto, cava libera per il corpo
 *     degli switch che passano attraverso le aperture;
 *   - aperture per i tasti: fori da 14 mm per switch MX, vani completi
 *     per ogni tasto, oppure piastra piena senza fori.
 *
 *  Stampa 3D: con field_bottom="solid" (default) il modello, orientato
 *  come da coordinate (fondo aperto in basso, tasselli in alto), si
 *  stampa SENZA supporti: l'unico ponte e' il soffitto delle cave
 *  dell'anello (gap di 3-4 mm fra pin/perni e pareti).
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
// Fondo del campo tasti: "solid" = stampa senza supporti (la femmina
// resta sotto l'anello di bordo); "open" = femmina anche sotto il campo
// tasti, ma la stampa richiede i supporti
field_bottom = "solid"; // [solid:Pieno - no supporti, open:Fondo aperto femmina - con supporti]

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
// Moduli
// ------------------------------------------------------------------

// Posiziona un mattoncino LEGO.scad con l'angolo su (cx, cy) in
// coordinate piastra, base a quota z.
// Attenzione: LEGO.scad disegna SEMPRE il lato lungo del block() lungo X
// (width e length vengono scambiati internamente): con rot=90 il
// mattoncino corre lungo Y. (width, length) = dimensioni logiche.
module brick_at(width, length, cx, cy, z, rot = 0, height = 1,
                stud_matrix = "", matrix_columns = 0, posts = true) {
    oL = max(width, length) * stud_pitch - 2 * wall_play;
    oW = min(width, length) * stud_pitch - 2 * wall_play;
    translate(rot == 0 ? [ cx + oL / 2, cy + oW / 2, z ]
                       : [ cx + oW / 2, cy + oL / 2, z ])
        rotate([0, 0, rot])
            block(width = width, length = length, height = height,
                  stud_rescale = stud_rescale,
                  with_posts = posts,
                  stud_matrix_string = stud_matrix,
                  stud_matrix_columns = matrix_columns);
}

// Anello di bordo + campo tasti.
module lego_plate() {
    h = plate_th / brick_unit_th;
    m = margin_studs;
    if (m > 0) {
        // Anello: mattoncini con tasselli sopra (solo bordo) e attacco
        // femmina sotto (fondo aperto con spline e pin/perni)
        brick_at(m, studs[0], 0, 0, 0, height = h);                              // frontale
        brick_at(m, studs[0], 0, stud_pitch * (studs[1] - m), 0, height = h);     // posteriore
        brick_at(1, studs[1] - 2 * m, 0, stud_pitch * m, 0,
                 rot = 90, height = h);                                          // sinistro
        brick_at(1, studs[1] - 2 * m, stud_pitch * (studs[0] - 1), stud_pitch * m, 0,
                 rot = 90, height = h);                                          // destro
    }
    // Campo tasti: copre tutta la piastra se margin_studs = 0
    key_floor(m > 0 ? studs[0] - 2 : studs[0],
              studs[1] - 2 * m,
              m > 0 ? stud_pitch : 0,
              stud_pitch * m,
              h);
}

// Campo tasti.
// field_bottom = "solid": piano pieno, la piastra si stampa senza
//   supporti (attacco femmina solo sotto l'anello di bordo, che e' comunque
//   l'unica zona utilizzabile con gli switch montati).
// field_bottom = "open": mattoncino a fondo aperto su tutta la piastra
//   (attacco femmina ovunque, senza tasselli ne' perni), ma il soffitto in
//   ponte sul campo richiede i supporti in stampa.
// NB saldatura: le parti LEGO sono giustapposte con 0.2 mm di gioco: il
// piano invadde di 0.5 mm le pareti interne dell'anello cosi' il tutto
// esce dalla stampa come pezzo unico e non come 5 pezzi staccati.
module key_floor(mid_l, mid_w, cx, cy, h) {
    if (field_bottom == "open") {
        rot_full = studs[0] >= studs[1] ? 0 : 90;
        no_studs = chr([ for (k = [0 : studs[0] * studs[1] - 1]) 46 ]); // tutta '.'
        brick_at(studs[1], studs[0], 0, 0, 0, rot = rot_full, height = h,
                 stud_matrix = no_studs,
                 matrix_columns = max(studs[0], studs[1]),
                 posts = false);
    } else {
        weld = margin_studs > 0 ? 0.5 : 0;
        translate([ cx - weld, cy - weld, 0 ])
            cube([ mid_l * stud_pitch - 2 * wall_play + 2 * weld,
                   mid_w * stud_pitch - 2 * wall_play + 2 * weld,
                   plate_th ]);
    }
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
    // Mattoncino standard agganciato SOTTO la piastra (attacco femmina):
    // il suo top entra nelle cave del fondo aperto, base a z = -9.6.
    brick_at(2, studs[0], 0, 0, -brick_unit_th);
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
