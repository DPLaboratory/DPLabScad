/*
 * Label rettangolare bicolore (stampa 3D multicolore -> 3MF)
 *
 * - Rettangolo con angoli arrotondati e bordo superiore smussato
 * - Testo centrato A FILO con la superficie (incassato, stesso livello della base)
 * - Cornice (linea) arrotondata a distanza regolabile dal bordo, anch'essa a filo
 *
 * Due parti / colori:
 *   - "base"   : piastra (colore 1)
 *   - "detail" : testo + cornice (colore 2)
 *
 * Export 3MF a colori: part = "all" ed esporta in 3MF.
 * In alternativa esporta part="base" e part="detail" e uniscili nello slicer.
 */

/* [Testo] */
label_lines  = ["USB"];     // una stringa per riga
font         = "Liberation Sans:style=Bold";
text_size    = 9;                 // altezza lettere (mm)
line_spacing = 1.25;
text_spacing = 1;
fit_text     = false;             // true: scala il testo per riempire la larghezza utile
text_margin  = 3;                 // margine tra cornice e testo

/* [Dimensioni] */
label_w   = 80;    // larghezza
label_h   = 30;    // altezza
corner_r  = 5;     // raggio angoli arrotondati
base_h    = 1.6;   // spessore piastra
edge_r    = 0.6;   // arrotondamento del bordo superiore (< frame_dist)
edge_steps = 8;

/* [Cornice] */
show_frame = true;
frame_dist = 2.0;  // distanza della cornice dal bordo esterno
frame_w    = 0.8;  // spessore della linea della cornice

/* [Dettagli] */
detail_h = 0.6;    // profondita' dell'incasso di testo e cornice
inlay    = true;   // true = a filo (consigliato), false = in rilievo sopra la base

/* [Colori e parte] */
color_base   = "#F2F2F2";
color_detail = "#111111";
part = "all";      // "all", "base", "detail"

$fn = 96;

// ---------------------------------------------------------------
// Forme 2D
// ---------------------------------------------------------------
module body2d() {
    r = min(corner_r, min(label_w, label_h) / 2 - 0.01);
    offset(r = r) square([label_w - 2 * r, label_h - 2 * r], center = true);
}

module frame2d() {
    if (show_frame)
        difference() {
            offset(delta = -frame_dist) body2d();
            offset(delta = -(frame_dist + frame_w)) body2d();
        }
}

module text2d() {
    n = len(label_lines);
    avail_w = label_w - 2 * (frame_dist + frame_w + text_margin);
    for (i = [0 : n - 1])
        translate([0, ((n - 1) / 2 - i) * text_size * line_spacing])
            if (fit_text)
                resize([avail_w, 0], auto = true)
                    text(label_lines[i], size = text_size, font = font,
                         halign = "center", valign = "center", spacing = text_spacing);
            else
                text(label_lines[i], size = text_size, font = font,
                     halign = "center", valign = "center", spacing = text_spacing);
}

module details2d() {
    frame2d();
    text2d();
}

// ---------------------------------------------------------------
// Corpi 3D
// ---------------------------------------------------------------
module base3d() {
    er = min(edge_r, base_h);
    n  = max(1, edge_steps);
    for (i = [0 : n - 1]) {
        z0 = i * base_h / n;
        zm = z0 + base_h / (2 * n);
        k  = base_h - zm;
        d  = (k < er) ? er - sqrt(er * er - (er - k) * (er - k)) : 0;
        translate([0, 0, z0])
            linear_extrude(height = base_h / n + 0.01)
                offset(delta = -d) body2d();
    }
}

module base_part() {
    difference() {
        base3d();
        if (inlay)
            translate([0, 0, base_h - detail_h])
                linear_extrude(height = detail_h + 1) details2d();
    }
}

module detail_part() {
    z0 = inlay ? base_h - detail_h : base_h;
    translate([0, 0, z0]) linear_extrude(height = detail_h) details2d();
}

module label() {
    if (part == "all" || part == "base")   color(color_base)   base_part();
    if (part == "all" || part == "detail") color(color_detail) detail_part();
}

label();
