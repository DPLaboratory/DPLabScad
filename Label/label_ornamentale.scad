/*
 * Label ornamentale bicolore (stampa 3D multicolore -> 3MF)
 *
 * Forma: rettangolo con angoli concavi, doppio bordo (sottile + spesso)
 * e giglio decorativo in alto al centro.
 *
 * Due parti / colori:
 *   - "base"   : piastra della label (colore 1)
 *   - "detail" : testo + bordi + giglio (colore 2)
 *
 * Export 3MF a colori: usa part = "all" ed esporta in 3MF
 * (OpenSCAD 2021.01 o snapshot recente, meglio con backend Manifold).
 * Alternativa: esporta separatamente part="base" e part="detail"
 * e uniscili nello slicer (Bambu Studio / Orca / PrusaSlicer).
 */

/* [Testo] */
label_lines   = ["Banca"];      // una stringa per riga
font          = "Liberation Sans:style=Bold";
text_size     = 9;                  // altezza lettere (mm)
line_spacing  = 1.25;
text_spacing  = 1;                  // spaziatura tra lettere
fit_text      = false;              // true: scala il testo per riempire la larghezza utile
text_margin   = 3;                  // margine tra bordo interno e testo

/* [Dimensioni] */
label_w   = 80;     // larghezza
label_h   = 35;     // altezza (senza giglio)
notch_r   = 7;      // raggio degli angoli concavi
tip_round = 0.6;    // arrotondamento delle punte degli angoli
base_h    = 1.6;    // spessore piastra
edge_r    = 0.6;    // raggio arrotondamento del bordo superiore (< border_offset)
edge_steps = 8;     // qualita' dell'arrotondamento

/* [Bordi] */
border_offset = 1.2;  // distanza del primo bordo dal contorno
outer_line    = 0.6;  // spessore linea esterna (sottile)
line_gap      = 0.8;  // spazio tra le due linee
inner_line    = 1.4;  // spessore linea interna (spessa)

/* [Dettagli] */
detail_h      = 0.6;    // altezza (o profondita') di testo, bordi e giglio
inlay         = false;  // false = rilievo sopra la base, true = incassato a filo
show_ornament = true;
ornament_scale = 1;

/* [Colori e parte] */
color_base   = "#F2F2F2";
color_detail = "#111111";
giglio = false; 
part = "all";   // "all", "base", "detail"

$fn = 96;

// ---------------------------------------------------------------
// Forme 2D
// ---------------------------------------------------------------
module notched(w, h, r) {
    difference() {
        square([w, h], center = true);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * w / 2, sy * h / 2]) circle(r = r);
    }
}

module round_tips(t) {
    if (t > 0) offset(r = t) offset(delta = -t) children();
    else children();
}

module body2d() {
    round_tips(tip_round) notched(label_w, label_h, notch_r);
}

module ring(a, b) {
    difference() {
        offset(delta = -a) body2d();
        offset(delta = -b) body2d();
    }
}

o1 = border_offset;
o2 = border_offset + outer_line + line_gap;
o_end = o2 + inner_line;

module rings2d() {
    ring(o1, o1 + outer_line);
    ring(o2, o_end);
}

// petalo a forma di lente, punta verso +y, base nell'origine
module leaf(L, W) {
    R = (L * L / 4 + W * W / 4) / W;
    intersection() {
        translate([-(R - W / 2), L / 2]) circle(r = R, $fn = 120);
        translate([ (R - W / 2), L / 2]) circle(r = R, $fn = 120);
    }
}

module ornament2d() {
    if (show_ornament)
        translate([0, label_h / 2 - 1.2])
            scale(ornament_scale) {
                leaf(10, 3.8);                       // petalo centrale
                for (m = [0, 1]) mirror([m, 0])      // petali laterali
                    translate([0.5, 1.0]) rotate(-62) leaf(7, 3);
                translate([-1.4, -0.2]) square([2.8, 2.2]);   // fascetta
                translate([0, 0.6]) circle(r = 1.3, $fn = 40);
            }
}

module text2d() {
    n = len(label_lines);
    avail_w = label_w - 2 * (o_end + text_margin);
    union() {
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
}

module details2d() {
    rings2d();
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
        k  = base_h - zm;                       // distanza dalla faccia superiore
        d  = (k < er) ? er - sqrt(er * er - (er - k) * (er - k)) : 0;
        translate([0, 0, z0])
            linear_extrude(height = base_h / n + 0.01)
                offset(delta = -d) body2d();
    }
}

module base_part() {
    difference() {
        base3d();
        // il giglio attraversa la piastra (e' nel colore dei dettagli)
        if (giglio) 
            translate([0, 0, -1]) linear_extrude(height = base_h + 2) ornament2d();
        // modalita' incassata: scavo per testo e bordi
        if (inlay)
            translate([0, 0, base_h - detail_h])
                linear_extrude(height = detail_h + 1) details2d();
    }
}

module detail_part() {
    z0 = inlay ? base_h - detail_h : base_h;
    union() {
        translate([0, 0, z0]) linear_extrude(height = detail_h) details2d();
        if (giglio)
            linear_extrude(height = base_h + (inlay ? 0 : detail_h)) ornament2d();
    }
}

module label() {
    if (part == "all" || part == "base")   color(color_base)   base_part();
    if (part == "all" || part == "detail") color(color_detail) detail_part();
}

label();
