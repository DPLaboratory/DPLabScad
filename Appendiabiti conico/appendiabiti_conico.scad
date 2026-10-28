// ============================================================
//  Appendiabiti conico da parete con vite nascosta (stile Yconic)
//  - Corpo cavo con piastrina posteriore forata per la vite
//  - Tappo frontale con linguette elastiche e "bead" che scatta
//    in una gola ricavata nel bordo interno del corpo
//
//  Asse Z: z = 0 e' il lato parete, z = L e' il fronte (tappo).
//  Montaggio: si avvita il corpo al muro (la testa della vite
//  sta DENTRO il cavo, si accede dal fronte), poi si preme il tappo.
// ============================================================

/* [Parte da visualizzare] */
// print = corpo + tappo in posizione di stampa | assembly = montato
// body / cap = singolo pezzo | section = sezione per controllo
part = "print"; // [print, assembly, body, cap, section]

/* [Dimensioni principali (mm)] */
L          = 48;    // lunghezza totale (sporgenza dal muro)
d_neck     = 20;    // diametro lato parete
d_head     = 48;    // diametro fronte
neck_len   = 6;     // tratto cilindrico lato parete
rim        = 6;     // tratto cilindrico del bordo frontale
wall       = 2.4;   // spessore pareti (3 se carichi pesanti)
back_t     = 4;     // spessore piastrina posteriore (dove appoggia la vite)

/* [Vite] */
screw_d    = 4.5;   // foro passante (vite da 4 mm)
head_d     = 9;     // diametro massimo testa vite (svasatura/appoggio)

/* [Tappo / clip] */
cap_t      = 1.6;   // spessore disco frontale
cap_gap    = 0.25;  // gioco radiale tappo-bordo (linea sottile visibile)
skirt_th   = 1.2;   // spessore gonna del tappo
bead_out   = 0.65;  // sporgenza del dentino di aggancio
clr        = 0.1;   // tolleranza assiale dentino-gola
n_slits    = 4;     // tagli sulla gonna per renderla elastica
slit_w     = 1.0;

$fn = 120;

// ---------------- derivati ----------------
rn      = d_neck / 2;
rh      = d_head / 2;
r_sock  = rh - wall;          // raggio interno dell'imbocco frontale
socket_d = rim;               // profondita' dell'imbocco cilindrico

// gola nel corpo (profilo con pendenza 45° sul lato stampa-sporgente)
g_ceil  = L - 3.2;            // faccia di ritenzione (piana)
g_d     = bead_out + 0.0;     // profondita' gola
g_flat  = 0.6;
g_floor = g_ceil - g_d - g_flat;

// ---------------- CORPO ----------------
module body_profile() {
    polygon([
        [0, 0],
        [rn, 0],
        [rn, neck_len],
        [rh, L - rim],
        [rh, L],
        [r_sock, L],
        [r_sock, L - socket_d],
        [rn - wall, neck_len],
        [rn - wall, back_t],
        [0, back_t]
    ]);
}

module groove() {
    rotate_extrude()
        polygon([
            [r_sock - 0.05, g_floor],
            [r_sock + g_d,  g_floor + g_d],
            [r_sock + g_d,  g_ceil],
            [r_sock - 0.05, g_ceil]
        ]);
}

module body() {
    difference() {
        rotate_extrude() body_profile();
        // foro vite
        translate([0, 0, -1]) cylinder(d = screw_d, h = back_t + 2);
        // svasatura sul lato interno per l'appoggio della testa
        translate([0, 0, back_t - (head_d - screw_d) / 2])
            cylinder(d1 = screw_d, d2 = head_d, h = (head_d - screw_d) / 2 + 0.01);
        groove();
    }
}

// ---------------- TAPPO ----------------
rs = r_sock - cap_gap;        // raggio esterno gonna
rc = r_sock - cap_gap;        // raggio disco frontale
zb = g_ceil - clr;            // faccia superiore del dentino

module cap() {
    difference() {
        union() {
            // disco frontale
            translate([0, 0, L - cap_t]) cylinder(r = rc, h = cap_t);
            // gonna
            translate([0, 0, zb - 1.15])
                difference() {
                    cylinder(r = rs, h = (L - cap_t) - (zb - 1.15) + 0.01);
                    translate([0, 0, -1])
                        cylinder(r = rs - skirt_th, h = (L - cap_t) - (zb - 1.15) + 2);
                }
            // dentino di aggancio: smusso 45° in basso (lato inserzione), piano sopra
            rotate_extrude()
                polygon([
                    [rs - 0.3, zb - bead_out - 0.5],
                    [rs,       zb - bead_out - 0.5],
                    [rs + bead_out, zb - 0.5],
                    [rs + bead_out, zb],
                    [rs - 0.3, zb]
                ]);
        }
        // tagli per elasticita' delle linguette
        for (i = [0 : n_slits - 1])
            rotate(i * 360 / n_slits + 45)
                translate([-slit_w / 2, 0, zb - 2])
                    cube([slit_w, rs + 2, (L - cap_t) - (zb - 2)]);
    }
}

// ---------------- OUTPUT ----------------
module print_layout() {
    // corpo a faccia frontale in basso (nessuna gola in sbalzo, cono a ~20°)
    translate([0, 0, L]) rotate([180, 0, 0]) body();
    // tappo con faccia visibile sul piatto
    translate([d_head + 10, 0, L]) rotate([180, 0, 0]) cap();
}

if (part == "print")         print_layout();
else if (part == "assembly") { body(); color("silver") cap(); }
else if (part == "body")     translate([0, 0, L]) rotate([180, 0, 0]) body();
else if (part == "cap")      translate([0, 0, L]) rotate([180, 0, 0]) cap();
else if (part == "section")
    difference() {
        union() { body(); color("silver") cap(); }
        translate([-100, -200, -10]) cube([200, 200, 100]);
    }
