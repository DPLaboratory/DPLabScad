// =====================================================================
//  Kickstand con cerniera PRINT-IN-PLACE (parametrico)
//  Ricostruito dall'analisi di obj_1_Body1.stl (piastra) e
//  obj_2_Body1.stl (braccio) – ispirato a MakerWorld 1607317.
//
//  Come funziona (misurato dagli STL):
//   - Asse cerniera VERTICALE (lungo Z), altezza totale H = 12 mm.
//     Si stampa in piedi: nessun supporto necessario.
//   - Il braccio ha una testa cilindrica (r = 2.0) con due perni conici
//     (sopra e sotto) che entrano in due sedi coniche ricavate nei
//     "tappi" della piastra. Gioco radiale 0.3 mm.
//   - Braccio spesso 2.0 mm, lato superiore passante per l'asse.
//     Stampato aperto di ~4.3 deg: richiuso ruota fino ad appoggiarsi
//     alla piastra (gioco 0.2 mm).
//   - Blocco: linguetta trapezoidale sul braccio + tasca sulla piastra.
//   - Dentini a gradino sul lato inferiore del braccio (appoggio telefono).
//   - Smusso 0.5 mm sul primo/ultimo strato (elephant foot).
//
//  Origine: asse cerniera. Piastra e braccio si sviluppano verso -X.
// =====================================================================

/* [Parte da generare] */
part = "both";            // [both, plate, arm]

/* [Generale] */
H            = 12;        // altezza = lunghezza del perno cerniera
chamfer      = 0.5;       // smusso primo/ultimo strato
$fn          = 72;

/* [Piastra] */
plate_len    = 46.9;      // lunghezza dalla cerniera
plate_t      = 2.3;       // spessore piastra
plate_gap    = 0.2;       // distanza piastra-braccio da chiuso
plate_slant  = 0.6;       // inclinazione dell'estremita' libera
tail_len     = 5.2;       // sporgenza dopo l'asse (dietro la cerniera)
knuckle_wall = 0.8;       // parete minima attorno alla sede (orig. ~0.2)

/* [Cerniera] */
r_head       = 2.0;       // raggio testa del braccio
clr          = 0.3;       // gioco radiale (stampa FDM 0.4mm: 0.25-0.35)
zclr         = 0.3;       // gioco verticale braccio-tappi
cap_h        = 2.0;       // spessore tappi sopra/sotto
cone_tip_r   = 1.0;       // raggio punta perno conico
cone_tip_z   = 1.2;       // quota punta perno
cone_top_z   = 3.1;       // quota dove il cono raggiunge r_head
open_max     = 110;       // angolo massimo di apertura (fessura anello)

/* [Braccio] */
arm_len      = 50.65;     // lunghezza dall'asse alla punta
arm_t        = 2.0;       // spessore braccio
print_angle  = 4.3;       // angolo di stampa (0 = chiuso, rischio fusione)
pad_h        = 1.95;      // altezza presa per il pollice sopra al braccio
pad_slant    = 1.9;       // sbalzo obliquo della punta
pad_top      = 0.75;      // tratto piano della presa

/* [Dentini di appoggio] */
n_teeth      = 6;
tooth_pitch  = 2.3;
tooth_h      = 0.45;
teeth_start  = 31.7;      // distanza dall'asse del primo dentino

/* [Blocco linguetta/tasca] */
tab_x1       = 39.9;      // bordo vicino all'asse (distanza)
tab_w        = 4.0;       // larghezza linguetta
tab_h        = 1.45;      // altezza linguetta
tab_base_z0  = 1.6;       // base linguetta (quota Z inferiore)
tab_tip_z0   = 3.0;       // cima linguetta (quota Z inferiore)

// ---------------------- derivati ----------------------
r_cav = r_head + clr;               // raggio sede
r_out = r_cav + knuckle_wall;       // raggio esterno nocca
r_clip = r_out + clr;               // raggio libero per il braccio nei tappi
eps = 0.01;

// ---------------------- utilita' ----------------------
// estrusione con smusso su primo e ultimo strato (a gradini)
module chamfered_extrude(h, c, n = 3) {
    if (c <= 0) linear_extrude(h) children();
    else {
        for (i = [0 : n - 1]) {
            d = c - (i + 0.5) * c / n;
            translate([0, 0, i * c / n])
                linear_extrude(c / n + eps) offset(delta = -d) children();
            translate([0, 0, h - c + i * c / n])
                linear_extrude(c / n + eps) offset(delta = -(i + 0.5) * c / n) children();
        }
        translate([0, 0, c]) linear_extrude(h - 2 * c) children();
    }
}

module round_convex(r) { offset(r = r) offset(delta = -r) children(); }

// ---------------------- profili 2D ----------------------
module plate2d() {
    round_convex(0.3) union() {
        polygon([[0, plate_gap],
                 [-plate_len - plate_slant, plate_gap],
                 [-plate_len, plate_gap + plate_t],
                 [0, plate_gap + plate_t]]);
        // nocca: raccordo tra piastra, anello e coda
        hull() {
            circle(r = r_out);
            translate([0, plate_gap]) square([tail_len, plate_t]);
        }
    }
}

module arm2d() {
    // corpo
    translate([-arm_len, -arm_t]) square([arm_len, arm_t]);
    // presa per il pollice
    round_convex(0.4) polygon([
        [-arm_len, -arm_t],
        [-arm_len + pad_slant, pad_h],
        [-arm_len + pad_slant + pad_top, pad_h],
        [-arm_len + pad_slant + pad_top, 0],
        [-arm_len + pad_slant + pad_top + 1, 0],
        [-arm_len + pad_slant + pad_top + 1, -arm_t]]);
    // dentini
    for (i = [0 : n_teeth - 1]) {
        x0 = -teeth_start - i * tooth_pitch;
        polygon([[x0, -arm_t + eps], [x0, -arm_t - tooth_h],
                 [x0 + tooth_pitch, -arm_t + eps]]);
    }
}

// profilo (r,z) della testa del braccio con i due coni
module head_profile() {
    polygon([[0, cone_tip_z], [cone_tip_r, cone_tip_z],
             [r_head, cone_top_z], [r_head, H - cone_top_z],
             [cone_tip_r, H - cone_tip_z], [0, H - cone_tip_z]]);
}

// ---------------------- linguetta / tasca ----------------------
module tab_shape(g = 0) {
    x0 = -tab_x1 - tab_w - g;
    w  = tab_w + 2 * g;
    hull() {
        translate([x0, -0.5, tab_base_z0 - g])
            cube([w, 0.5 + g, H - 2 * tab_base_z0 + 2 * g]);
        translate([x0, tab_h - eps, tab_tip_z0 - g])
            cube([w, eps + g, H - 2 * tab_tip_z0 + 2 * g]);
    }
}

// ---------------------- PIASTRA (rossa) ----------------------
module plate() {
    R = r_out + 3;
    slot_pts = concat(
        [[0, plate_gap], [-R, plate_gap]],
        [for (a = [180 : 5 : 180 + open_max]) [R * cos(a), R * sin(a)]]);
    difference() {
        chamfered_extrude(H, chamfer) plate2d();
        // sede testa: cilindro + sedi coniche (profilo testa + gioco)
        rotate_extrude()
            intersection() {
                offset(delta = clr) head_profile();
                translate([0, -1]) square([100, H + 2]);
            }
        // fessura per il passaggio del braccio (solo zona centrale)
        translate([0, 0, cap_h]) linear_extrude(H - 2 * cap_h) polygon(slot_pts);
        // tasca di blocco
        tab_shape(clr);
    }
}

// ---------------------- BRACCIO (blu) ----------------------
module arm() {
    rotate([0, 0, print_angle]) union() {
        // corpo a tutta altezza, lontano dalla cerniera (tappi liberi)
        chamfered_extrude(H, chamfer)
            difference() { arm2d(); circle(r = r_clip); }
        // collo: solo nella zona centrale, tra i tappi
        translate([0, 0, cap_h + zclr])
            linear_extrude(H - 2 * (cap_h + zclr)) arm2d();
        // testa con perni conici
        rotate_extrude() head_profile();
        // linguetta di blocco
        tab_shape(0);
    }
}

// ---------------------- assemblaggio ----------------------
if (part == "both" || part == "plate") plate();
if (part == "both" || part == "arm")   arm();
