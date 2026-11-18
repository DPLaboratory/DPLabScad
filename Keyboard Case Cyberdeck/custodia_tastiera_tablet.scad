/*
 * CUSTODIA PER TASTIERA MECCANICA CON COPERCHIO-SUPPORTO PER TABLET
 * ---------------------------------------------------------------
 * - Base (vassoio) che contiene la tastiera + vano posteriore (cavi / alloggio leveraggio)
 * - Coperchio che da chiuso protegge la tastiera e da aperto diventa il supporto del tablet
 * - Cerniera a QUADRILATERO ARTICOLATO (4 bar linkage) su ENTRAMBI i lati:
 *     il coperchio non ruota su un perno fisso, ma scorre all'indietro e si inclina,
 *     appoggiandosi dietro la tastiera (come nelle foto di riferimento).
 *
 * Il leveraggio e' calcolato con la sintesi a due posizioni (chiuso / aperto):
 *   scegli dove deve stare il coperchio da chiuso e da aperto, e gli assi dei
 *   perni della base vengono ricavati automaticamente.
 *
 * Strati lungo Y (da dentro verso fuori) su ogni lato:
 *   parete base | orecchio del coperchio | biella 1 | biella 2
 *
 * USO
 *   mostra = "assieme"  -> modello montato, con animazione ($t) oppure apertura fissa
 *   mostra = "stampa"   -> pezzi disposti in piano per la stampa
 *   mostra = "base" | "coperchio" | "orecchio" | "biella1" | "biella2"  -> singolo pezzo (per export STL)
 *
 * PERNI: aste da 3 mm (filo da saldatura / barra di acciaio / filamento 3 mm).
 */

/* ===================== PARAMETRI ===================== */
mostra   = "assieme";   // "assieme","stampa","base","coperchio","orecchio","biella1","biella2"
apertura = -1;          // 0 = chiuso ... 1 = aperto ; -1 = usa $t (animazione)
mostra_fantasmi = true; // tastiera e tablet trasparenti nell'assieme

// --- ANIMAZIONE (View > Animate, es. FPS 20, Steps 150) ---
// "nessuna"  : modello montato, usa 'apertura' (0..1) come posa fissa
// "tutto"    : montaggio pezzo per pezzo -> apertura -> tablet che si appoggia
// "assembla" : solo il montaggio (vista esplosa che si ricompone)
// "apri"     : solo apertura/chiusura del quadrilatero + tablet
animazione  = "nessuna";
camera_auto = true;     // imposta da script la vista per l'animazione
t_manuale   = -1;       // >=0 forza un istante fisso dell'animazione (0..1), ignora $t

// --- Tastiera (dimensioni esterne, tasti compresi) ---
kb_w = 320;   // larghezza (asse Y)
kb_d = 124;   // profondita' (asse X)
kb_h = 32;    // altezza totale tastiera con keycap
tol  = 0.6;   // gioco attorno alla tastiera (per lato)

// --- Tablet ---
tablet_w = 250;  // lato lungo (orizzontale)
tablet_h = 175;  // lato corto (appoggiato lungo il coperchio)
tablet_t = 8;    // spessore

// --- Spessori ---
floor_t  = 3;    // fondo
wall_f   = 3;    // parete anteriore / posteriore / divisoria
wall_s   = 5;    // pareti laterali
rear_top = 3;    // piano superiore del vano posteriore
top_gap  = 3;    // keycap sotto il bordo del vassoio
t_lid    = 3;    // spessore piastra coperchio
lip_t    = 4;    // spessore battuta inferiore del tablet
guide_t  = 4;    // spessore guide laterali del tablet
guide_l  = 45;   // lunghezza guide laterali

// --- Cerniera ---
pin_d    = 3;     // diametro perni
link_t   = 4;     // spessore biella (e orecchio)
ear_t    = 4;
g        = 0.6;   // gioco tra strati
link_w   = 12;    // larghezza biella
ear_r    = 7;     // raggio dell'orecchio attorno ai perni
ang_open = 70;    // inclinazione del coperchio da aperto (gradi dall'orizzontale)
open_dx  = 6;     // distanza del bordo basso del coperchio aperto oltre il vassoio tastiera
lp1_u    = 25;    // posizione lungo il coperchio del perno 1
lp2_u    = 85;    // posizione lungo il coperchio del perno 2
piv_v    = 12;    // profondita' dei perni sotto la faccia inferiore del coperchio
zb1      = 14;    // altezza (Z) del perno di base 1
zb2      = 18;    // altezza (Z) del perno di base 2

// --- Magneti opzionali (chiusura) ---
usa_magneti = true;
mag_d = 4.2;  mag_h = 2;  // magnete 4x2 mm (foro con 0.2 di gioco)

$fn = 48;

/* ===================== GEOMETRIA DERIVATA ===================== */
D_kb  = kb_d + 2*wall_f;              // profondita' esterna vano tastiera
Ztop  = floor_t + kb_h + top_gap;     // altezza bordo vassoio
Lu    = max(tablet_h + 20, D_kb + 40);// lunghezza coperchio = profondita' totale
Wi    = kb_w + 2*tol;                 // larghezza interna
Wt    = Wi + 2*wall_s;                // larghezza esterna vassoio
yw    = Wt/2;                         // faccia esterna parete laterale (lato +Y)
Wl    = Wt + 2*(g + ear_t);           // larghezza coperchio

// strati lato +Y
y_e0  = yw + g;       y_e1  = y_e0 + ear_t;          // orecchio
y_l10 = y_e1 + g;     y_l11 = y_l10 + link_t;        // biella 1
y_l20 = y_l11 + g;    y_l21 = y_l20 + link_t;        // biella 2

lp1 = [lp1_u, -piv_v];
lp2 = [lp2_u, -piv_v];

/* ---- funzioni 2D ---- */
function rot(a) = [[cos(a), -sin(a)], [sin(a), cos(a)]];
function mulv(M, p) = [M[0][0]*p[0] + M[0][1]*p[1], M[1][0]*p[0] + M[1][1]*p[1]];
function pose(O, a, p) = O + mulv(rot(a), p);
function circ(c1, r1, c2, r2, pick) =
    let(dd = norm(c2 - c1),
        a  = (r1*r1 - r2*r2 + dd*dd) / (2*dd),
        h  = sqrt(max(r1*r1 - a*a, 0)),
        e  = (c2 - c1)/dd,
        m  = c1 + a*e,
        n  = [-e[1], e[0]])
    m + pick*h*n;

/* ---- sintesi a due posizioni ---- */
Oc  = [0, Ztop];                      // origine coperchio da chiuso
Oo  = [D_kb + open_dx, Ztop];         // origine coperchio da aperto (poggia sul piano posteriore)

P1c = pose(Oc, 0, lp1);  P2c = pose(Oc, 0, lp2);
P1o = pose(Oo, ang_open, lp1);  P2o = pose(Oo, ang_open, lp2);

function bisett(pc, po, zb) =
    let(m = (pc + po)/2, d = po - pc, n = [-d[1], d[0]]/norm(d),
        s = (zb - m[1]) / n[1])
    m + s*n;

B1 = bisett(P1c, P1o, zb1);   // perno di base 1
B2 = bisett(P2c, P2o, zb2);   // perno di base 2

L1  = norm(P1c - B1);         // lunghezza biella 1
L2  = norm(P2c - B2);         // lunghezza biella 2
d12 = norm(P2c - P1c);        // distanza perni sul coperchio

pick = (norm(circ(P1c, d12, B2, L2, 1) - P2c) < 0.05) ? 1 : -1;

a0 = atan2(P1c[1] - B1[1], P1c[0] - B1[0]);
a1 = atan2(P1o[1] - B1[1], P1o[0] - B1[0]);
da = ((a1 - a0 + 540) % 360) - 180;

/* ---- fasi dell'animazione ---- */
function sm(x) = let(c = min(max(x, 0), 1)) c*c*(3 - 2*c);
function ph(t, a, b) = sm((t - a)/(b - a));

tt     = (t_manuale >= 0) ? t_manuale : $t;
asm_t  = (animazione == "tutto")    ? tt/0.5 :
         (animazione == "assembla") ? tt     : 1;             // avanzamento montaggio 0..1
t_ap   = (animazione == "tutto")    ? ph(tt, 0.55, 0.80) :
         (animazione == "apri")     ? ph(tt, 0.10, 0.70) :
         (animazione == "assembla") ? 0 :
         (apertura >= 0) ? apertura : 0;
t_tab  = (animazione == "tutto")    ? ph(tt, 0.83, 0.97) :
         (animazione == "apri")     ? ph(tt, 0.75, 0.95) :
         (animazione == "assembla") ? 0 : 1;                  // tablet che scivola sulla battuta

p_kb   = ph(asm_t, 0.00, 0.20);   // tastiera nella base
p_ear  = ph(asm_t, 0.12, 0.30);   // orecchi nelle tasche del coperchio
p_lid  = ph(asm_t, 0.30, 0.50);   // coperchio sulla base
p_l1   = ph(asm_t, 0.50, 0.65);   // biella 1
p_l2   = ph(asm_t, 0.62, 0.77);   // biella 2
p_pin  = ph(asm_t, 0.77, 1.00);   // perni

function didascalia() =
    (animazione == "nessuna") ? "" :
    (animazione == "apri")
        ? (tt < 0.75 ? "Apertura: il quadrilatero fa scorrere e inclinare il coperchio" : "Il tablet scivola sulla battuta") :
    (animazione == "assembla" || tt < 0.5)
        ? (asm_t < 0.12 ? "1. La tastiera entra nella base" :
           asm_t < 0.30 ? "2. Gli orecchi si incollano nelle tasche del coperchio" :
           asm_t < 0.50 ? "3. Il coperchio si appoggia sulla base" :
           asm_t < 0.62 ? "4. Biella 1 (strato interno)" :
           asm_t < 0.77 ? "5. Biella 2 (strato esterno)" :
                          "6. Perni da 3 mm nei 4 snodi (su entrambi i lati)") :
    (tt < 0.55 ? "Montato" :
     tt < 0.82 ? "7. Apertura: il quadrilatero fa scorrere e inclinare il coperchio" :
                 "8. Il tablet scivola sulla battuta e si appoggia");

if (animazione != "nessuna") echo(didascalia());
$vpr = camera_auto ? [62, 0, 215] : [55, 0, 25];
$vpt = camera_auto ? [100, 0, 70] : [0, 0, 0];
$vpd = camera_auto ? 1250 : 500;
a_t   = a0 + da*t_ap;
P1_t  = B1 + L1*[cos(a_t), sin(a_t)];
P2_t  = circ(P1_t, d12, B2, L2, pick);
ang_t = atan2(P2_t[1] - P1_t[1], P2_t[0] - P1_t[0]);
O_t   = P1_t - mulv(rot(ang_t), lp1);
a2_t  = atan2(P2_t[1] - B2[1], P2_t[0] - B2[0]);

echo("Lunghezza biella 1 [mm]:", L1, " biella 2 [mm]:", L2);
echo("Perno base 1 (x,z):", B1, " perno base 2 (x,z):", B2);
echo("Larghezza totale vassoio:", Wt, " coperchio:", Wl, " profondita':", Lu, " altezza:", Ztop);

/* ===================== UTILITA' ===================== */
// estrude una forma 2D (x,z) tra y0 e y1
module prof(y0, y1) {
    rotate([90,0,0]) translate([0,0,-y1]) linear_extrude(y1 - y0) children();
}
// perno cilindrico lungo Y
module pin(p, y0, y1, d = pin_d) {
    translate([p[0], y0, p[1]]) rotate([-90,0,0]) cylinder(d = d, h = y1 - y0);
}
// duplica per i due lati (+Y e -Y)
module lati() { children(); mirror([0,1,0]) children(); }

/* ===================== BASE ===================== */
module base() {
    difference() {
        translate([0, -Wt/2, 0]) cube([Lu, Wt, Ztop]);
        // vano tastiera
        translate([wall_f, -Wi/2, floor_t]) cube([kb_d, Wi, Ztop]);
        // vano posteriore (cavita' sotto il piano superiore)
        translate([D_kb, -Wi/2, floor_t])
            cube([Lu - D_kb - wall_f, Wi, Ztop - floor_t - rear_top]);
        // passaggio cavo nella parete divisoria
        translate([D_kb - wall_f - 1, -Wi/2 + 8, floor_t + 2]) cube([wall_f + 2, 14, 8]);
        // fori ciechi dei perni di base (solo parete laterale)
        lati() {
            pin(B1, yw - 4, yw + 1, pin_d + 0.1);
            pin(B2, yw - 4, yw + 1, pin_d + 0.1);
        }
        // magneti sul bordo delle pareti laterali
        if (usa_magneti) lati()
            for (x = [30, 100]) translate([x, yw - wall_s/2, Ztop - mag_h]) cylinder(d = mag_d, h = mag_h + 0.1);
    }
}

/* ===================== ORECCHIO (solidale al coperchio) ===================== */
module ear2d() {   // coordinate coperchio (u,v)
    difference() {
        hull() {
            translate(lp1) circle(r = ear_r);
            translate(lp2) circle(r = ear_r);
            translate([lp1[0] - ear_r, 0]) square([lp2[0] - lp1[0] + 2*ear_r, t_lid - 1]);
        }
        translate(lp1) circle(d = pin_d + 0.4);
        translate(lp2) circle(d = pin_d + 0.4);
    }
}
module orecchio() { linear_extrude(ear_t) ear2d(); }

/* ===================== COPERCHIO (sistema di riferimento u,v) ===================== */
lip_h = tablet_t + 3;
gy    = tablet_w/2 + 0.6;
module coperchio() {
    difference() {
        union() {
            translate([0, -Wl/2, 0]) cube([Lu, Wl, t_lid]);
            // battuta inferiore
            translate([0, -gy - guide_t, t_lid - 0.01]) cube([lip_t, 2*(gy + guide_t), lip_h]);
            // guide laterali
            lati() translate([0, gy, t_lid - 0.01]) cube([guide_l, guide_t, lip_h]);
        }
        // tasche per i tenoni degli orecchi (aperte verso l'esterno)
        lati() prof(y_e0 - 0.2, y_e1 + 0.3)
            offset(delta = 0.2) intersection() {
                ear2d();
                translate([0, 0]) square([400, t_lid - 1]);
            }
        // magneti
        if (usa_magneti) lati()
            for (x = [30, 100]) translate([x, yw - wall_s/2, -0.1]) cylinder(d = mag_d, h = mag_h + 0.1);
    }
}

/* ===================== BIELLE ===================== */
module link2d(L) {
    difference() {
        hull() { circle(d = link_w); translate([L, 0]) circle(d = link_w); }
        circle(d = pin_d + 0.4);
        translate([L, 0]) circle(d = pin_d + 0.4);
    }
}
module biella1() { linear_extrude(link_t) link2d(L1); }
module biella2() { linear_extrude(link_t) link2d(L2); }

/* ===================== ASSIEME ===================== */
module assieme() {
    color("SteelBlue") base();

    // coperchio + orecchi nella posa corrente (cala dall'alto durante il montaggio)
    translate([0, 0, 140*(1 - p_lid)])
    translate([O_t[0], 0, O_t[1]]) rotate([0, -ang_t, 0]) {
        color("Peru", 0.95) coperchio();
        color("Goldenrod") lati() translate([0, 55*(1 - p_ear), 0]) prof(y_e0, y_e1) ear2d();
        if (mostra_fantasmi && t_tab > 0)
            color("LightSteelBlue", 0.85)
                translate([lip_t + 0.3 + 70*(1 - t_tab), -tablet_w/2, t_lid]) cube([tablet_h, tablet_w, tablet_t]);
    }

    // bielle (entrano lateralmente)
    color("OrangeRed") lati() {
        translate([0, 55*(1 - p_l1), 0]) prof(y_l10, y_l11) translate(B1) rotate(a_t)  link2d(L1);
        translate([0, 55*(1 - p_l2), 0]) prof(y_l20, y_l21) translate(B2) rotate(a2_t) link2d(L2);
    }

    // perni (aste da 3 mm) infilati dall'esterno
    color("Silver") lati() translate([0, 45*(1 - p_pin), 0]) {
        pin(B1,   yw - 4, y_l11);
        pin(B2,   yw - 4, y_l21);
        pin(P1_t, y_e0,   y_l11);
        pin(P2_t, y_e0,   y_l21);
    }

    // tastiera fantasma (cala dall'alto)
    if (mostra_fantasmi)
        color("Gray", 0.75)
            translate([wall_f + 0.3, -kb_w/2, floor_t + 110*(1 - p_kb)]) cube([kb_d - 0.6, kb_w, kb_h]);

    // didascalia 3D (ancorata in basso nella vista)
    if (animazione != "nessuna")
        color("Black") translate([100, 0, 70])
            rotate([0, 0, 215]) rotate([62, 0, 0])    // rivolta verso la camera
                translate([0, -205, 0])
                    linear_extrude(1) text(didascalia(), size = 12, halign = "center");
}

/* ===================== DISPOSIZIONE PER LA STAMPA ===================== */
module stampa() {
    base();
    translate([0, Wt/2 + Wl/2 + 15, 0]) translate([0, 0, 0]) coperchio();
    // 2 orecchi, 2 bielle1, 2 bielle2
    for (i = [0:1]) {
        translate([Lu + 25, -Wt/2 + i*60, 0]) orecchio();
        translate([Lu + 25, -Wt/2 + 130 + i*20, 0]) biella1();
        translate([Lu + 25, -Wt/2 + 170 + i*20, 0]) biella2();
    }
}

/* ===================== SELEZIONE ===================== */
if      (mostra == "assieme")   assieme();
else if (mostra == "stampa")    stampa();
else if (mostra == "base")      base();
else if (mostra == "coperchio") coperchio();
else if (mostra == "orecchio")  orecchio();
else if (mostra == "biella1")   biella1();
else if (mostra == "biella2")   biella2();
