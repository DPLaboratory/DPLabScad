/*
 *  keyCaps.scad
 *  ------------------------------------------------------------------
 *  Keycap compatibile Cherry MX con attacco LEGO maschio sulla faccia
 *  superiore: ogni tasto si comporta come la faccia superiore di un
 *  mattoncino LEGO (tasselli pitch 8 mm, diametro 4.8, altezza 1.8) e
 *  sotto ha lo stem per lo switch Cherry MX.
 *
 *  Progetto di riferimento: Lowprofile/DPL_keycap_mx_low_profile.scad.
 *  Le parti utili sono state INCORPORATE in questo file (non usato come
 *  libreria): stem MX (stem/stem_cross), corpo con bordo smussato o
 *  arrotondato (rsq/edge_slice/outer_body), dish, testo flat/engraved,
 *  generazione del set e ponticelli di aderenza al piatto.
 *
 *  Differenze rispetto al riferimento:
 *   - tasselli LEGO sulla faccia superiore (griglia 8 mm centrata,
 *     quantita' in funzione della larghezza del tasto);
 *   - pareti dritte dalla base (skirt pieno): il riferimento usava una
 *     gonna ridotta (cap_h_out) per il profilo basso;
 *   - i ponticelli di stampa sono al livello del piatto (z = 0..link_h),
 *     collegano le basi delle pareti dei keycap adiacenti;
 *   - la faccia superiore deve essere piana (dish_depth = 0) perche' i
 *     tasselli vi poggiano; il testo "flat" va usato sapendo che puo'
 *     sovrapporsi ai tasselli (default "none").
 *  ------------------------------------------------------------------
 */

$fn = 64;

// ---------- Modalita' di costruzione ----------
build_mode = "single";  // "single" = un solo keycap (usa key_text e key_u)
                        // "set"    = un keycap per ogni elemento dell'array "keys"

// ---------- Parametri principali ----------
pitch      = 19.05;  // passo MX standard
gap        = 1.05;   // spazio tra keycap (19.05 - 18.00)
key_u      = 1;      // larghezza in unita' (1, 1.25, 1.5, ...) - solo build_mode = "single"
cap_w      = pitch * key_u - gap;  // 18.00 per 1u
cap_d      = pitch - gap;          // 18.00
cap_h      = 5.0;    // altezza del corpo (i tasselli LEGO sporgono oltre)
corner_r   = 2.5;    // raggio angoli alla base
wall       = 1.4;    // spessore pareti
top_t      = 1.2;    // spessore del tetto (sotto il piano superiore)

// ---------- Bordo superiore ----------
edge_style = "round"; // "chamfer" = smusso 45 gradi | "round" = arrotondato (raccordo)
edge_size  = 1.2;     // dimensione: smusso 1.2mm orizz. x 1.2mm vert., oppure raggio 1.2mm
round_steps = 12;     // risoluzione dell'arrotondamento (piu' alto = piu' liscio)

// ---------- Dish (cavita' circolare) ----------
// Con i tasselli LEGO la faccia superiore deve restare piana: dish_depth = 0.
dish_dia   = 12.0;
dish_depth = 0;

// ---------- Testo ----------
text_mode     = "none";    // "none" | "flat" (rilievo) | "engraved" (scavato)
text_color    = "white";
key_text      = "A";       // solo build_mode = "single"
text_size     = 3;
text_font     = "Liberation Sans:style=Bold";
text_spacing  = 1;
text_rotate   = 0;
text_offset   = [0, 0];
text_raise    = 0.0;
text_engrave  = 0.2;
line_spacing  = 1.2;
sep_char      = "|";

// ---------- Tasselli LEGO (attacco maschio standard) ----------
lego_pitch   = 8;    // passo tasselli LEGO
lego_stud_d  = 4.8;  // diametro tassello
lego_stud_h  = 1.8;  // altezza tassello
lego_margin  = 1.0;  // bordo libero dal ciglio del tasto
lego_rescale = 1.00; // correzione per la stampante (1.05 = +5%)

// ---------- Stem Cherry MX ----------
stem_d      = 5.6;    // diametro esterno cilindro
stem_h      = 3.3;    // profondita' croce dal basso
cross_len   = 4.15;   // lunghezza braccio croce (nominale 4.1)
cross_wid   = 1.35;   // larghezza braccio croce (nominale 1.3-1.4)
tol         = 0.05;   // tolleranza stampa 3D

// ---------- Set di keycap ----------
// Ogni elemento di "keys" puo' essere:
//   "Q"                -> keycap 1u con il testo "Q"
//   ["Tab", 1.5]       -> keycap larga 1.5u con il testo "Tab"
//   ["Esc", 1.25, 4.5] -> come sopra, con altezza testo forzata a 4.5 mm
keys = ["", "", "", ""];

set_cols       = 6;      // keycap per riga sul piatto di stampa
set_gap        = 3;      // spazio tra i keycap sul piatto (mm)
auto_fit_text  = true;   // riduce il testo se non entra nella faccia superiore
text_char_w    = 0.7;    // larghezza media di un carattere = text_char_w * size
text_margin    = 0.5;    // margine libero ai lati del testo (mm)

// ---------- Collegamento tra keycap (aderenza al piatto) ----------
// Ponticelli sottili al livello del piatto (z = 0..link_h) che saldano le
// basi delle pareti di keycap adiacenti: aumentano la superficie del primo
// strato. Dopo la stampa si tagliano via.
link_mode = "grid";   // "none" = nessun collegamento
                      // "rows" = collega ogni keycap al successivo nella stessa riga
                      // "grid" = come "rows" + collega ogni keycap a quello della riga sotto
link_h    = 0.4;      // altezza ponticelli (mm): 1-2 strati, facili da staccare
link_w    = 2.0;      // larghezza ponticelli (mm)
link_grip = 0.6;      // quanto il ponticello entra sulla parete di ogni keycap (mm)

// ---------- Derivati ----------
ceil_h  = cap_h - top_t;        // quota del soffitto della cavita'
skirt_h = cap_h - edge_size;    // quota dove inizia il bordo superiore
is_round = (edge_style == "round");
steps  = is_round ? round_steps : 1;

// rientro orizzontale e quota verticale al passo i (0..steps)
function inset(i) = is_round ? edge_size * (1 - cos(90 * i / steps))
                             : edge_size * i / steps;
function rise(i)  = is_round ? edge_size * sin(90 * i / steps)
                             : edge_size * i / steps;

// ---------- Funzioni per il set ----------
function key_label(k) = is_list(k) ? str(k[0]) : str(k);
function key_units(k) = (is_list(k) && len(k) > 1) ? k[1] : 1;
function key_width(k) = pitch * key_units(k) - gap;

// altezza del testo: forzata (3o elemento) oppure ridotta per entrare nella faccia superiore
function fit_size(label, w) =
    let(est   = len(label) * text_size * text_char_w,
        avail = w - 2 * edge_size - 2 * text_margin)
    (auto_fit_text && est > avail) ? text_size * avail / est : text_size;
function key_tsize(k) = (is_list(k) && len(k) > 2) ? k[2]
                                                   : fit_size(key_label(k), key_width(k));

// posizione sul piatto: i keycap sono affiancati per riga, con larghezze diverse
function row_start(i) = floor(i / set_cols) * set_cols;
function sum_w(from, to) = from >= to ? 0
                                      : key_width(keys[from]) + set_gap + sum_w(from + 1, to);
function key_x(i) = sum_w(row_start(i), i) + key_width(keys[i]) / 2;
function key_y(i) = -floor(i / set_cols) * (cap_d + set_gap);

// ---------- Moduli ----------
module rsq(w, d, r, h = 0.01) {
    linear_extrude(h)
        offset(r) square([w - 2*r, d - 2*r], center = true);
}

module edge_slice(i, w) {
    s = inset(i);
    translate([0, 0, skirt_h + rise(i) - 0.01])
        rsq(w - 2*s, cap_d - 2*s, max(corner_r - s, 0.5), 0.01);
}

// corpo esterno: pareti dritte dalla base + bordo superiore (smusso o raccordo)
module outer_body(w) {
    rsq(w, cap_d, corner_r, skirt_h);
    for (i = [0 : steps - 1])
        hull() { edge_slice(i, w); edge_slice(i + 1, w); }
}

module dish() {
    R = (pow(dish_dia/2, 2) + pow(dish_depth, 2)) / (2 * dish_depth);
    translate([0, 0, cap_h + R - dish_depth]) sphere(r = R, $fn = 160);
}

// cavita' a croce dello stem
module stem_cross() {
    translate([0, 0, -0.01]) {
        translate([-(cross_len + tol)/2, -(cross_wid + tol)/2, 0])
            cube([cross_len + tol, cross_wid + tol, stem_h]);
        translate([-(cross_wid + tol)/2, -(cross_len + tol)/2, 0])
            cube([cross_wid + tol, cross_len + tol, stem_h]);
    }
}

module stem() {
    difference() {
        cylinder(d = stem_d, h = ceil_h + 0.2);
        stem_cross();
    }
}

// funzioni split caratteri (legende a due righe con il separatore "|")
function join(l, i=0) = i >= len(l) ? "" : str(l[i], join(l, i+1));
function substr(s, st, n) = n <= 0 ? "" : join([for (i=[st:st+n-1]) s[i]]);
function split(s, sep="|", i=0, start=0, acc=[]) =
    i == len(s) ? concat(acc, [substr(s, start, i-start)]) :
    s[i] == sep ? split(s, sep, i+1, i+1, concat(acc, [substr(s, start, i-start)])) :
    split(s, sep, i+1, start, acc);

// sagoma 2D del testo, centrata
module text2d(label, tsize) {
    lines = is_list(label) ? label : split(label, sep_char);
    n = len(lines);
    translate(text_offset)
        rotate(text_rotate)
            for (i = [0 : n-1])
                translate([0, ((n-1)/2 - i) * tsize * line_spacing])
                    text(lines[i], size = tsize, font = text_font,
                         halign = "center", valign = "center",
                         spacing = text_spacing);
}

// quota del fondo del dish al centro
dish_floor = cap_h - dish_depth;

// ---------- Tasselli LEGO ----------
// Griglia 8 mm centrata sulla faccia superiore; il numero di tasselli per
// lato dipende dalla larghezza/profondita' del keycap.
module lego_studs(w, d) {
    cols = max(1, floor((w - 2 * lego_margin - lego_stud_d * lego_rescale) / lego_pitch) + 1);
    rows = max(1, floor((d - 2 * lego_margin - lego_stud_d * lego_rescale) / lego_pitch) + 1);
    for (i = [0 : cols - 1], j = [0 : rows - 1])
        translate([ (i - (cols - 1) / 2) * lego_pitch,
                    (j - (rows - 1) / 2) * lego_pitch,
                    cap_h - 0.01 ])
            cylinder(d = lego_stud_d * lego_rescale, h = lego_stud_h + 0.01);
}

// ---------- Keycap ----------
// singolo keycap: stem MX sotto, corpo, tasselli LEGO sopra
module keycap(label = key_text, u = key_u, tsize = text_size) {
    w = pitch * u - gap;

    assert(dish_depth == 0,
           "dish_depth > 0: i tasselli LEGO richiedono la faccia superiore piana");

    union() {
        difference() {
            outer_body(w);
            // cavita' interna (pareti dritte)
            translate([0, 0, -0.01])
                rsq(w - 2*wall, cap_d - 2*wall,
                    max(corner_r - wall, 0.5), ceil_h + 0.01);
            if (dish_depth > 0) dish();
            // testo scavato: fondo piatto
            if (text_mode == "engraved")
                translate([0, 0, dish_floor - text_engrave])
                    color(text_color) linear_extrude(text_engrave + dish_depth + 1)
                        text2d(label, tsize);
        }
        stem();
        // testo in rilievo sulla faccia superiore (attenzione: puo' toccare i tasselli)
        if (text_mode == "flat")
            color(text_color)
                translate([0, 0, cap_h])
                    linear_extrude(cap_h + text_raise - (dish_floor - 0.1))
                        text2d(label, tsize);
        lego_studs(w, cap_d);
    }
}

// set completo: un keycap per ogni elemento di "keys", disposti a griglia sul piatto
module keycap_set() {
    for (i = [0 : len(keys) - 1]) {
        k = keys[i];
        translate([key_x(i), key_y(i), 0])
            keycap(key_label(k), key_units(k), key_tsize(k));
    }
}

// ponticello piatto tra due punti, al livello del piatto (z = 0..link_h)
module link(a, b) {
    hull() {
        translate([a[0], a[1], 0]) cylinder(d = link_w, h = link_h, $fn = 24);
        translate([b[0], b[1], 0]) cylinder(d = link_w, h = link_h, $fn = 24);
    }
}

// ponticelli tra le basi delle pareti dei keycap del set
module keycap_links() {
    n = len(keys);
    difference() {
        union() {
            for (i = [0 : n - 1]) {
                // keycap successivo nella stessa riga
                if (i + 1 < n && row_start(i + 1) == row_start(i))
                    link([ key_x(i) + key_width(keys[i]) / 2 - link_grip, key_y(i) ],
                         [ key_x(i + 1) - key_width(keys[i + 1]) / 2 + link_grip, key_y(i + 1) ]);
                // keycap nella riga sotto
                if (link_mode == "grid" && i + set_cols < n)
                    link([ key_x(i), key_y(i) - cap_d / 2 + link_grip ],
                         [ key_x(i + set_cols), key_y(i + set_cols) + cap_d / 2 - link_grip ]);
            }
        }
        // la croce di ogni stem resta libera
        for (i = [0 : n - 1])
            translate([key_x(i), key_y(i), 0]) stem_cross();
    }
}

// ---------- Output ----------
echo(str("Keycap ", key_u, "u: ", cap_w, " x ", cap_d, " x ",
         cap_h + lego_stud_h, " mm (corpo ", cap_h, " + tasselli ", lego_stud_h, ")"));

if (build_mode == "set") {
    keycap_set();
    if (link_mode != "none") keycap_links();
}
else keycap();
