// ============================================================================
//  Custodia per tastiera meccanica con coperchio-stand per tablet
//  ---------------------------------------------------------------------------
//  La base e' una vasca: vano frontale aperto per la tastiera, vano posteriore
//  cavo per i cavi e gli accessori, chiuso da una piastra superiore (che fa
//  anche da finecorsa dell'apertura) e apribile tramite un portellino a
//  incasso con foro pollice.
//  Base, coperchio e portellino si possono stampare in DUE META'
//  con giunzione a INCASTO A PETTINE (parametri splitta, splitta_porta):
//  denti press-fit allineano le parti, si oppongono allo strappo e la colla
//  completa il fissaggio. Vedere i moduli meta_incastro_A/B, le viste
//  mostra="incasto" e la sezione 6.1 del README.
//  Il coperchio NON ruota su un perno fisso: e' vincolato da una cerniera a
//  QUADRILATERO ARTICOLATO (four-bar linkage) presente su ENTRAMBI i lati,
//  quindi retrocede e si inclina contemporaneamente. Aperto a 70 gradi forma
//  uno stand per tablet; il bordo inferiore del coperchio si appoggia sulla
//  piastra posteriore, che fa da finecorsa contro il peso del tablet.
//
//  Riferimenti: X = profondita' (fronte->retro), Y = larghezza, Z = altezza.
//  La cinematica e' risolta nel profilo 2D (x,z) ed estrusa lungo Y.
//
//  Quadrilatero articolato (per lato):
//      B1 - P1 = biella1  (B1 = perno fisso nella parete della base)
//      B2 - P2 = biella2  (B2 = perno fisso nella parete della base)
//      P1 - P2 = coppia (il coperchio con le orecchie incollate)
//  Livelli lungo Y, dall'interno verso l'esterno:
//      parete base | orecchio | biella1 | biella2  (separati dal gioco g)
//
//  Sintesi a due posate (verificata in Python/numpy prima della stesura):
//      B1 = [97.058, 14], B2 = [180.526, 18]
//      L1 = 73.050, L2 = 95.861, d12 = 60
//  Verifiche superate (minimi su 501 pose intermedie):
//      continuita' 0->1 senza cambio di ramo (max passo 2.4e-5 mm)
//      sottocoperchio/tastiera >= 3.0 mm; sottocoperchio/piastra-bordi >= 0
//      P2-biella1 = 9.9 >= 8 | B1-biella2 = 11.0 >= 8 | P1-biella2 = 23.0 >= 20
//      B1-coperchio = 24 >= 15 | B2-coperchio = 20 >= 15
//      dz/dt del baricentro < 0 vicino alla posa aperta: la gravita' spinge
//      il coperchio CONTRO il finecorsa (piastra posteriore), non verso
//      l'apertura libera.
//
//  Solo OpenSCAD standard, nessuna libreria esterna.
// ============================================================================

/* [Globali] */
$fn  = 32;

/* [Visualizzazione] */
mostra      = "assieme"; // ["assieme","stampa","base","base_a","base_b","coperchio","coperchio_a","coperchio_b","porta_a","porta_b","incasto","orecchio","biella1","biella2","portellino"]
animazione  = "nessuna"; // ["nessuna","tutto","assembla","apri"]
t_manuale   = 0;         // >0: forza l'istante dell'animazione (0..1)
camera_auto = true;      // false: disattiva la camera impostata qui

/* [Tastiera] */
kb_w     = 320;   // larghezza tastiera lungo Y [mm]
kb_d     = 124;   // profondita' lungo X [mm]
kb_h     = 32;    // altezza totale, keycap inclusi [mm]
tol      = 0.6;   // gioco diametro/pareti [mm]

/* [Tablet] */
tablet_w = 250;   // larghezza tablet lungo Y [mm]
tablet_h = 175;   // altezza tablet lungo il coperchio [mm]
tablet_t = 8;     // spessore tablet [mm]

/* [Spessori] */
floor_t  = 3;     // fondo della vasca [mm]
wall_f   = 3;     // parete frontale e tramezzo [mm]
wall_s   = 5;     // pareti laterali [mm]
rear_top = 3;     // piastra di chiusura vano cavi [mm]
top_gap  = 3;     // gioco sopra i keycap a coperchio chiuso [mm]
t_lid    = 3;     // spessore piastra coperchio [mm]
lip_t    = 4;     // spessore (lungo u) del fermo del tablet [mm]
guide_t  = 4;     // spessore/altezza delle guide laterali tablet [mm]
guide_l  = 45;    // lunghezza delle guide laterali lungo u [mm]

/* [Cerniera] */
pin_d    = 3;     // diametro perni (barre da 3 mm, non stampate) [mm]
link_t   = 4;     // spessore bielle lungo Y [mm]
ear_t    = 4;     // spessore orecchie lungo Y [mm]
g        = 0.6;   // gioco fra livelli adiacenti lungo Y [mm]
link_w   = 12;    // larghezza bielle (profilo a fessura) [mm]
ear_r    = 7;     // raggio dei perni dell'orecchio [mm]
ang_open = 70;    // angolo di apertura [gradi]
open_dx  = 6;     // arretramento dell'origine coperchio nella posa aperta [mm]
lp1_u    = 25;    // ascissa locale del perno coperchio P1 [mm]
lp2_u    = 85;    // ascissa locale del perno coperchio P2 [mm]
piv_v    = 12;    // profondita' dei perni sotto la faccia posteriore [mm]
zb1      = 14;    // quota z del perno fisso B1 [mm]
zb2      = 18;    // quota z del perno fisso B2 [mm]

/* [Accessori] */
usa_magneti = true; // magneti 4x2 sul bordo superiore delle pareti, 2 per lato
mag_d    = 4;     // diametro magnete [mm]
mag_h    = 2;     // altezza magnete (profondita' dell'alloggio) [mm]
mag_p1   = 0.25;  // posizione 1 lungo Lu (frazione) [-]
mag_p2   = 0.75;  // posizione 2 lungo Lu (frazione) [-]

/* [Dettagli di stampa/montaggio] */
foro_prof = 4;    // profondita' fori ciechi dei perni B (dalla faccia esterna) [mm]
pass_w    = 20;   // larghezza passaggio cavi nel tramezzo [mm]
pass_h    = 10;   // altezza passaggio cavi [mm]
stampa_perni  = false;        // perni stampati nel piano di stampa (per la prova mini)
perno_stamp_d = pin_d - 0.1;  // diametro perno stampato (sottodimensionato vs foro)

/* [Vano posteriore apribile (cavi e accessori)] */
vano_d = 50;      // profondita' interna del vano posteriore [mm]

porta_aperta  = true;              // abilita il portellino del vano posteriore
porta_l       = 45;                // lunghezza portellino lungo X [mm]
porta_cornice = 20;                // cornice libera per lato verso le pareti [mm]
porta_t       = 2;                 // spessore portellino (minore di rear_top) [mm]
porta_lip     = 3;                 // larghezza del bordo di appoggio nel fondo [mm]
porta_gioco   = 0.25;              // gioco laterale portellino/seduta [mm]
porta_foro_l  = 24;                // lunghezza foro pollice lungo Y [mm]
porta_foro_d  = 10;                // larghezza foro pollice lungo X [mm]
porta_foro_dx = 8;                 // distanza foro pollice dal bordo frontale [mm]

/* [Suddivisione per la stampa (incasto a pettine)] */
splitta     = true;  // divide base e coperchio in due meta' stampabili separatamente
seam_base_y = 0;     // quota Y della giunzione della base [mm]
seam_cop_y  = 0;     // quota Y della giunzione del coperchio, rif. locale [mm]
n_denti     = 6;     // numero di denti per giunzione (alternati ai vuoti)
dent_d      = 10;    // profondita' del dente attraverso la giunzione [mm]
inc_gioco   = 0.25;  // gioco laterale e di fondo dente/predella [mm]
splitta_porta = true;  // divide anche il portellino (lungo ~280 mm) in due meta'
n_denti_porta = 2;     // denti della giunzione del portellino
dent_d_porta  = 8;     // profondita' del dente del portellino (pezzo sottile) [mm]

// ---------------------- GRANDEZZE DERIVATE --------------------------------
D_kb = kb_d + 2*wall_f;                       // profondita' vano tastiera
Ztop = floor_t + kb_h + top_gap;              // quota del bordo della vasca
Lu   = max(tablet_h + 20, D_kb + 40, D_kb + vano_d + wall_f); // lunghezza coperchio = fondo
Wi   = kb_w + 2*tol;                          // larghezza interna
Wt   = Wi + 2*wall_s;                         // larghezza totale base
Wl   = Wt + 2*(g + ear_t);                    // larghezza totale coperchio

// Camera (usata se camera_auto = true; con animazioni in anteprima).
// Per le viste di layout (stampa, incasto, pezzi in assetto di stampa) la
// camera si allarga per inquadrare l'intero piano: il centro e' stimato a
// 2*Lu (tetto della lunghezza del piano di stampa) e la distanza copre
// l'ingombro di ~850 x 800 mm del layout completo.
/* [Camera] */
vpr_cam = [62, 0, 215];
vpt_cam = [100, 0, 70];
vpd_cam = 1250;
vpr_lay = [62, 0, 215];
vpt_lay = [2*Lu, 0, 0];
vpd_lay = 2800;

// Livelli lungo Y (lato +Y; lato -Y e' speculare)
Yw0  = Wi/2;            // faccia interna parete
Yw1  = Yw0 + wall_s;    // faccia esterna parete  (= Wt/2)
Ye0  = Yw1 + g;         // faccia interna orecchio
Ye1  = Ye0 + ear_t;     // faccia esterna orecchio (= Wl/2)
Yl10 = Ye1 + g;         // faccia interna biella1
Yl11 = Yl10 + link_t;   // faccia esterna biella1
Yl20 = Yl11 + g;        // faccia interna biella2
Yl21 = Yl20 + link_t;   // faccia esterna biella2

// lunghezze dei perni di montaggio (valgono anche per quelli stampati)
perno_lung_B1 = Yl11 - Yw1 + foro_prof;         // parete + zona orecchio + biella1
perno_lung_B2 = Yl21 - Yw1 + foro_prof;         // parete + zona orecchio + biella2
perno_lung_P1 = ear_t + g + link_t;             // orecchio + biella1
perno_lung_P2 = ear_t + g + link_t + g + link_t; // orecchio + (aria biella1) + biella2

prof_poch = t_lid - g;                        // profondita' tasca tenone
h_fermo   = tablet_t + 3;                     // fermo = spessore tablet + 3 mm
rp_foro   = (pin_d + 0.4)/2;                  // raggio fori perni (gioco 0.4)

// Giunzione a pettine: il corso della giunzione (lungo X per la base, lungo u
// per il coperchio, entrambi lunghi Lu) e' diviso in 2*n_denti celle
// alternate dente/vuoto; il dente e' la cella pari.
dent_l = Lu/(2*n_denti);                      // lunghezza dente lungo la giunzione [mm]

// Portellino del vano posteriore (a incasso, a filo della piastra)

porta_w       = Wi - 2*porta_cornice; // larghezza portellino lungo Y [mm]

porta_x = D_kb + open_dx + (Lu - wall_f - D_kb - open_dx)/2; // centro portellino

// giunzione del portellino, nel suo riferimento (y 0..dw): di default sta
// appena dietro il foro pollice, cosi' il foro resta intero nella meta' B
seam_porta_y = (porta_w - 2*porta_gioco)/2 - porta_foro_l;  // [mm]

// Fissaggio coperchio-orecchio: fori passanti per viti o perni, in aggiunta
// alla colla del tenone (2 fori per orecchio, nella fascia dell'orecchio).
// Il foro attraversa piastra + tenone + corpo dell'orecchio (esce in basso):
// si puo' usare un perno da vit_d mm (gli stessi della cerniera) incollato,
// oppure una vite passante con dado sotto l'orecchio. Con vit_svaso > 0 si
// ottiene il sedile per testa conica (es. M3: vit_d=3, vit_svaso=1.6).
// Nota: sopra il tenone la piastra resta sottile (t_lid - prof_poch), quindi
// consigliate testa cilindrica + rondella, non testa svasata profonda.
/* [Usa viti orecchio] */
usa_viti_orecchio = true;  // abilita i fori passanti coperchio-orecchio
vit_d     = 3;             // diametro nominale vite/perno [mm]
vit_gioco = 0.2;           // gioco del foro [mm]
vit_svaso = 0;             // profondita' svaso sulla faccia tablet [mm], 0 = no
vit_svaso_d = 6.5;         // diametro svaso [mm]

vit_foro = vit_d + vit_gioco;                     // diametro effettivo del foro
vit_u1 = lp1_u + (lp2_u - lp1_u)/4;               // foro 1 lungo il tenone
vit_u2 = lp2_u - (lp2_u - lp1_u)/4;               // foro 2 lungo il tenone
vit_y0 = Wl/2 - ear_t/2;                          // centro della fascia orecchio

assert(abs(Ye1 - Wl/2) < 1e-6, "i livelli Y non tornano con Wl");
assert(lp2_u > lp1_u && piv_v > ear_r,
       str("geometria orecchio non valida:  lp1_u = ", lp1_u, "  lp2_u = ", lp2_u,
           "  piv_v = ", piv_v, "  ear_r = ", ear_r,
           "  (serve lp2_u > lp1_u e piv_v > ear_r)"));
assert(!porta_aperta || porta_t < rear_top,
       "portellino troppo spesso: serve porta_t < rear_top per l'incasso");
assert(!porta_aperta || (porta_x - porta_l/2 >= D_kb + open_dx &&
                         porta_x + porta_l/2 <= Lu - wall_f),
       "portellino fuori dal vano posteriore");
assert(!porta_aperta || porta_w/2 + porta_lip <= Wi/2 - 1,
       "portellino troppo largo rispetto alle pareti laterali");
assert(!porta_aperta || (porta_foro_dx + porta_foro_d < porta_l - 2*porta_gioco &&
                         porta_foro_l < porta_w - 2*porta_lip),
       "foro pollice fuori dal portellino");
assert(!usa_viti_orecchio || vit_foro <= ear_t - 0.8,
       "foro di fissaggio troppo largo per lo spessore dell'orecchio");
assert(!usa_viti_orecchio || (vit_u1 > lp1_u && vit_u2 < lp2_u),
       "fori di fissaggio fuori dal tenone");
assert(vit_svaso == 0 || vit_svaso < t_lid,
       "svaso piu' profondo dello spessore del coperchio");
assert(!splitta || n_denti >= 1, "n_denti deve essere almeno 1");
assert(!splitta || (dent_d > 0 && dent_d < min(Wt, Wl)/2 - 1),
       "dent_d troppo profondo rispetto alla larghezza dei pezzi");
assert(!splitta || abs(seam_base_y) < Wt/2 - 1,
       "giunzione base fuori dal pezzo");
assert(!splitta || abs(seam_cop_y) < Wl/2 - 1,
       "giunzione coperchio fuori dal pezzo");
assert(!splitta || (inc_gioco > 0 && inc_gioco <= 0.6),
       "inc_gioco deve essere > 0 e contenuto (max 0.6)");
assert(!splitta_porta || (seam_porta_y > dent_d_porta + 1 &&
                          seam_porta_y < (porta_w - 2*porta_gioco) - dent_d_porta - 1),
       "giunzione portellino troppo vicina ai bordi");
assert(!splitta_porta ||
       (seam_porta_y + dent_d_porta + inc_gioco < (porta_w - 2*porta_gioco)/2 - porta_foro_l/2 ||
        seam_porta_y > (porta_w - 2*porta_gioco)/2 + porta_foro_l/2),
       "la giunzione del portellino finisce nel foro pollice: sposta seam_porta_y");

vista_layout = mostra == "stampa" || mostra == "incasto" ||
               mostra == "base"    || mostra == "coperchio" ||
               mostra == "base_a"  || mostra == "base_b"    ||
               mostra == "coperchio_a" || mostra == "coperchio_b" ||
               mostra == "porta_a" || mostra == "porta_b";

$vpr = camera_auto ? (vista_layout ? vpr_lay : vpr_cam) : [55, 0, 25];
$vpt = camera_auto ? (vista_layout ? vpt_lay : vpt_cam) : [100, 0, 40];
$vpd = camera_auto ? (vista_layout ? vpd_lay : vpd_cam) : 900;

// ------------------ CINEMATICA 2D NEL PIANO (x, z) -------------------------
// Il coperchio vive in un riferimento locale (u, v): u lungo il coperchio a
// partire dal bordo inferiore, v normale alla piastra con v = 0 sulla faccia
// POSTERIORE (quella che si stampa a terra e guarda la tastiera da chiuso).
// I perni del coperchio sono sotto la faccia posteriore: lp = [u, -piv_v].

function rot2(a, v) = [v[0]*cos(a) - v[1]*sin(a), v[0]*sin(a) + v[1]*cos(a)];
function dot2(u, v) = u[0]*v[0] + u[1]*v[1];

// angolo di un vettore 2D in gradi, quadranti gestiti (evita ambiguita' atan2)
function ang_v(v) = v[0] == 0 ? (v[1] > 0 ? 90 : v[1] < 0 ? -90 : 0) :
                    v[0] > 0 ? atan(v[1]/v[0]) :
                    (v[1] >= 0 ? atan(v[1]/v[0]) + 180 : atan(v[1]/v[0]) - 180);

lp1 = [lp1_u, -piv_v];                        // perno coperchio P1 (locale)
lp2 = [lp2_u, -piv_v];                        // perno coperchio P2 (locale)

Oc = [0, Ztop];                               // origine coperchio, chiuso
Oo = [D_kb + open_dx, Ztop];                  // origine coperchio, aperto

Pc1 = Oc + lp1;  Pc2 = Oc + lp2;              // perni coperchio, chiuso
Po1 = Oo + rot2(ang_open, lp1);               // perni coperchio, aperto
Po2 = Oo + rot2(ang_open, lp2);

// perno fisso: sull'asse del segmento (posa chiusa <-> aperta), con z = zb
function bialetta(Pc, Po, zb) =
    let(m = (Pc + Po)/2, d = Po - Pc, L = norm(d),
        n = [-d[1], d[0]]/L, s = (zb - m[1])/n[1])
    m + s*n;

B1 = bialetta(Pc1, Po1, zb1);
B2 = bialetta(Pc2, Po2, zb2);

L1  = norm(Pc1 - B1);                         // lunghezza biella1
L2  = norm(Pc2 - B2);                         // lunghezza biella2
d12 = norm(Pc2 - Pc1);                        // distanza fra i perni coperchio

a0c = ang_v(Pc1 - B1);                        // angolo biella1, chiusa
a1o = ang_v(Po1 - B1);                        // angolo biella1, aperta
da1 = a1o - a0c;
da  = da1 - 360*floor((da1 + 180)/360);       // differenza in (-180, 180]

// intersezione di due cerchi: due radici, scelta con 'segno' (+1 / -1)
function intersez_cerchi(c0, r0, c1, r1, segno) =
    let(d = c1 - c0, D = norm(d),
        a = (r0*r0 - r1*r1 + D*D)/(2*D),
        h = sqrt(max(r0*r0 - a*a, 0)),
        p = c0 + a*d/D,
        n = [-d[1], d[0]]/D)
    p + segno*h*n;

// ramo corretto: quello che nella posa CHIUSA restituisce esattamente Pc2
segno_ramo = let(d = B2 - Pc1, D = norm(d),
                 a = (d12*d12 - L2*L2 + D*D)/(2*D),
                 p = Pc1 + a*d/D, n = [-d[1], d[0]]/D)
             (dot2(Pc2 - p, n) >= 0 ? 1 : -1);

// --- posa generica t in [0, 1]: 0 = chiusa, 1 = aperta ---
function posa_biella1(t) = a0c + t*da;                        // angolo biella1
function P1_posa(t)      = B1 + L1*[cos(posa_biella1(t)),
                                   sin(posa_biella1(t))];
function P2_posa(t)      = intersez_cerchi(P1_posa(t), d12, B2, L2, segno_ramo);
function ang_coperchio(t) = ang_v(P2_posa(t) - P1_posa(t));   // angolo coperchio
function O_coperchio(t)  = P1_posa(t) - rot2(ang_coperchio(t), lp1);

// punto del mondo -> riferimento locale del coperchio alla posa t
function loc_cop(P, t) = rot2(-ang_coperchio(t), P - O_coperchio(t));

echo(str("SINTESI:  L1 = ", L1, "  L2 = ", L2, "  d12 = ", d12));
echo(str("PERNI FISSI:  B1 = ", B1, "   B2 = ", B2));

// ---------------- VERIFICHE CINEMATICHE A RUNTIME --------------------------
// distanza punto-segmento nel piano
function d_ps(p, a, b) =
    let(ab = b - a, tt = max(0, min(1, dot2(p - a, ab)/dot2(ab, ab))))
    norm(p - (a + tt*ab));
// distanza punto-coperchio (segmento dall'origine, lungo Lu, alla posa t)
function d_cop(p, t) =
    let(O = O_coperchio(t),
        u = [cos(ang_coperchio(t)), sin(ang_coperchio(t))])
    d_ps(p, O, O + u*Lu);

campioni = [for (i = [0:20]) i/20];
min_P2L1  = min([for (t = campioni) d_ps(P2_posa(t), B1, P1_posa(t))]);
min_B1L2  = min([for (t = campioni) d_ps(B1, B2, P2_posa(t))]);
min_P1L2  = min([for (t = campioni) d_ps(P1_posa(t), B2, P2_posa(t))]);
min_B1cop = min([for (t = campioni) d_cop(B1, t)]);
min_B2cop = min([for (t = campioni) d_cop(B2, t)]);
min_B2L1  = min([for (t = campioni) d_ps(B2, B1, P1_posa(t))]);
// soglia percorsa per i contatti perno-corpo biella: metta larghezza biella +
// raggio perno (a scala reale fa ~7.7, la specifica chiedeva 8)
soglia_pin = link_w/2 + rp_foro;
echo(str("VERIFICHE (min su 21 pose):  P2-biella1 = ", min_P2L1, " (>=", soglia_pin, ")  |  ",
         "B1-biella2 = ", min_B1L2, " (>=", soglia_pin, ")  |  P1-biella2 = ", min_P1L2,
         "  |  B1-coperchio = ", min_B1cop, "  |  ",
         "B2-coperchio = ", min_B2cop, "  |  B2-biella1 = ", min_B2L1, " (>=", soglia_pin, ")"));
echo(str("PERNI (2 copie ciascuno; diam. ", perno_stamp_d, " se stampati):  P1 = ",
         perno_lung_P1, "  B1 = ", perno_lung_B1, "  P2 = ", perno_lung_P2,
         "  B2 = ", perno_lung_B2));

// ---------------------------- MODULI BASE ----------------------------------
// Estrusione lungo Y di un profilo 2D (x = u, y = v): occupa Y in [-h, 0],
// la coordinata y del profilo diventa la quota Z.
module estrusa_y(h) rotate([90, 0, 0]) linear_extrude(height = h) children();

// ------------------------------- 1. BASE -----------------------------------
module base() {
    difference() {
        translate([0, -Wt/2, 0]) cube([Lu, Wt, Ztop]);
        // vano tastiera (aperto in alto)
        translate([wall_f, -Wi/2, floor_t])
            cube([D_kb - 2*wall_f, Wi, Ztop]);
        // vano posteriore cavi (chiuso sopra dalla piastra rear_top)
        translate([D_kb, -Wi/2, floor_t])
            cube([Lu - D_kb - wall_f, Wi, Ztop - rear_top - floor_t]);
        // passaggio cavi nel tramezzo
        translate([D_kb - wall_f - tol, -pass_w/2, floor_t])
            cube([wall_f + 2*tol, pass_w, pass_h]);
        // fori ciechi dei perni B1/B2: dalla faccia ESTERNA delle pareti
        for (sx = [-1, 1], B = [B1, B2])
            translate([B[0], sx*Yw1, B[1]])
                rotate([sx < 0 ? -90 : 90, 0, 0])
                    cylinder(h = foro_prof, d = pin_d + 0.1);
        // alloggi magneti sul bordo superiore delle pareti laterali
        if (usa_magneti)
            for (sx = [-1, 1], f = [mag_p1, mag_p2])
                translate([f*Lu, sx*(Yw0 + wall_s/2), Ztop - mag_h])
                    cylinder(h = mag_h + 2, d = mag_d);
        // portellino del vano posteriore: seduta a spoglio profonda porta_t
        // (il portellino resta a filo del piano) + luce con bordo di appoggio
        if (porta_aperta) {
            translate([porta_x - porta_l/2, -porta_w/2, Ztop - porta_t])
                cube([porta_l, porta_w, porta_t + 1]);        // seduta
            translate([porta_x - porta_l/2 + porta_lip,
                       -porta_w/2 + porta_lip, Ztop - rear_top - 1])
                cube([porta_l - 2*porta_lip, porta_w - 2*porta_lip,
                      rear_top + 2]);                         // luce + bordo
        }
    }
}

// -------------------- PORTELLINO DEL VANO POSTERIORE -----------------------
// Parte separata, incassata a filo con la piastra posteriore: poggia sul
// bordo perimetrale (larghezza porta_lip) e si estrae spingendo dal foro
// pollice. Con il coperchio principale chiuso resta trattenuto in sede.
module portellino() {
    dl = porta_l - 2*porta_gioco;                  // quotato per il gioco
    dw = porta_w - 2*porta_gioco;
    difference() {
        cube([dl, dw, porta_t]);
        // foro pollice: fessura arcuata passante presso il bordo frontale
        hull()
            for (yy = [-1, 1])
                translate([porta_foro_dx,
                           dw/2 + yy*(porta_foro_l - porta_foro_d)/2, -1])
                    cylinder(h = porta_t + 2, d = porta_foro_d);
    }
}

module portellino_in_posa() color("SteelBlue")
    translate([porta_x - porta_l/2 + porta_gioco,
               -(porta_w - 2*porta_gioco)/2, Ztop - porta_t])
        portellino();

// ------------------------------ 2. COPERCHIO -------------------------------
// Solido nel riferimento locale (u, v), con la faccia posteriore in v = 0
// (stampabile a faccia posteriore sul letto). Larghezza simmetrica su Y.
module coperchio_solido() {
    difference() {
        union() {
            // piastra + fermo inferiore del tablet (su tutta la larghezza)
            translate([0, Wl/2, 0]) estrusa_y(Wl)
                union() {
                    square([Lu, t_lid]);
                    translate([0, t_lid]) square([lip_t, h_fermo]);
                }
            // guide laterali del tablet, a ridosso del fermo
            for (sy = [-1, 1])
                translate([lip_t, sy*(tablet_w/2 + guide_t), t_lid])
                    estrusa_y(guide_t) square([guide_l, guide_t]);
        }
        // tasche per i tenoni delle orecchie, aperte verso l'esterno
        for (sy = [-1, 1])
            translate([lp1_u - g, sy > 0 ? Wl/2 - ear_t : -Wl/2, -1])
                cube([lp2_u - lp1_u + 2*g, ear_t, prof_poch + 1]);
        // fori passanti di fissaggio orecchie: attraversano la piastra e, a
        // montaggio fatto, proseguono nel tenone/corpo dell'orecchio
        if (usa_viti_orecchio)
            for (sy = [-1, 1], u_i = [vit_u1, vit_u2]) {
                translate([u_i, sy*vit_y0, -1])
                    cylinder(h = t_lid + 2, d = vit_foro);
                if (vit_svaso > 0)
                    translate([u_i, sy*vit_y0, t_lid - vit_svaso])
                        cylinder(h = vit_svaso + 1, d1 = vit_foro,
                                 d2 = vit_svaso_d);
            }
    }
}

// applica la posa t del coperchio ai figli (costruiti nel riferimento locale)
module in_coperchio(t)
    translate([O_coperchio(t)[0], 0, O_coperchio(t)[1]])
        rotate([0, -ang_coperchio(t), 0]) children();

module coperchio_in_posa(t) in_coperchio(t) color("Peru") coperchio_solido();

// ------------------- SUDDIVISIONE IN META' PER LA STAMPA -------------------
// La giunzione e' un INCASTO A PETTINE sul piano y = y0: la meta' A
// (y < y0) porta i DENTI che si incastrano nelle PREDELLE della meta' B
// (y > y0), maggiorate di inc_gioco. Le meta' si uniscono scorrendo lungo
// +Y: il pettine allinea le parti e si oppone a strappo e taglio, la colla
// completa il fissaggio. I denti attraversano tutto lo spessore del pezzo
// (piastra + fermo per il coperchio; fondo e pareti per la base) e le zone
// critiche (tasche orecchie, fori viti, portellino) sono lontane dalla
// giunzione. Le meta' incollate riproducono il pezzo intero: assieme e
// animazione usano la geometria intera, il piano di stampa le meta'.

module meta_incastro_A(y0, L, n_d, d_d, gioco) {
    seg = L/(2*n_d);                           // celle alternate dente/vuoto
    intersection() {
        union() {
            // meta' A: tutto il solido con y < y0
            translate([0, y0 - 1000, -1]) cube([L, 1000, 1000]);
            // denti a pettine: partono da dentro la meta' A e sporgono oltre
            for (i = [0:n_d-1])
                translate([2*i*seg, y0 - 0.5, -1])
                    cube([seg, 0.5 + d_d, 1000]);
        }
        children(0);
    }
}

module meta_incastro_B(y0, L, n_d, d_d, gioco) {
    seg = L/(2*n_d);
    difference() {
        intersection() {
            // meta' B: tutto il solido con y >= y0
            translate([0, y0, -1]) cube([L, 1000, 1000]);
            children(0);
        }
        // predelle: cavita' dei denti, maggiorate del gioco (lato e fondo)
        for (i = [0:n_d-1])
            translate([2*i*seg - gioco, y0, -1])
                cube([seg + 2*gioco, d_d + gioco, 1000]);
    }
}

module meta_base_A() meta_incastro_A(seam_base_y, Lu, n_denti, dent_d, inc_gioco) base();
module meta_base_B() meta_incastro_B(seam_base_y, Lu, n_denti, dent_d, inc_gioco) base();
module meta_coperchio_A() meta_incastro_A(seam_cop_y, Lu, n_denti, dent_d, inc_gioco) coperchio_solido();
module meta_coperchio_B() meta_incastro_B(seam_cop_y, Lu, n_denti, dent_d, inc_gioco) coperchio_solido();
// portellino: giunzione nel suo riferimento (y 0..porta_w-2*porta_gioco),
// comb lungo X con denti piu' fitti e meno profondi (pezzo sottile)
module meta_porta_A() meta_incastro_A(seam_porta_y, porta_l, n_denti_porta, dent_d_porta, inc_gioco) portellino();
module meta_porta_B() meta_incastro_B(seam_porta_y, porta_l, n_denti_porta, dent_d_porta, inc_gioco) portellino();

// ------------------------------ 3. ORECCHIO --------------------------------
// Profilo 2D nel riferimento del coperchio: inviluppo convesso di due cerchi
// centrati sui perni P1/P2, piu' il tenone che entra nella tasca della piastra.
module profilo_orecchio() {
    difference() {
        union() {
            hull() {
                translate(lp1) circle(r = ear_r);
                translate(lp2) circle(r = ear_r);
            }
            // tenone nella piastra
            translate([lp1_u, -piv_v])
                square([lp2_u - lp1_u, piv_v + prof_poch]);
        }
        // fori dei perni P1/P2 (orecchio <-> bielle): vanno TAGLIATI,
        // non aggiunti (errore corretto: prima erano nell'unione)
        for (lp = [lp1, lp2]) translate(lp) circle(d = pin_d + 0.4);
        // zona libera per i perni B1/B2: fascia circolare (raggio L_i attorno
        // a lp_i) spazzata dal perno fisso durante l'apertura, delimitata in
        // angolo dal percorso reale. Con i valori predefiniti resta fuori dal
        // profilo (nessun taglio), ma protegge al variare dei parametri.
        zona_libera_2d(B1, lp1, L1);
        zona_libera_2d(B2, lp2, L2);
    }
}

// helper per la zona libera: angoli srotolati del percorso di B attorno a lp
function wrap180(d) = d - 360*floor((d + 180)/360);
function passi_B(B, lp, N = 24) =
    [for (k = [0:N-1])
        wrap180(ang_v(loc_cop(B, (k + 1)/N) - lp) -
                ang_v(loc_cop(B, k/N) - lp))];
function somma(v, i = 0, acc = 0) =
    i >= len(v) ? acc : somma(v, i + 1, acc + v[i]);
function theta_B(B, lp, N = 24) =
    let(p  = passi_B(B, lp, N),
        sg = somma(p) >= 0 ? 1 : -1,         // verso dello spazzamento
        t0 = ang_v(loc_cop(B, 0) - lp) - 5*sg)
    concat([t0],
           [for (i = [1:N]) t0 + somma([for (k = [0:i-1]) p[k]])],
           [t0 + somma(p) + 5*sg]);          // margine angolare a fine corsa

module zona_libera_2d(B, lp, L) {
    thetas = theta_B(B, lp);
    Rg   = L + rp_foro + 2;
    r_in = max(L - rp_foro, 0.01);           // tutela per parametri estremi
    intersection() {
        difference() {
            translate(lp) circle(r = L + rp_foro);
            translate(lp) circle(r = r_in);
        }
        polygon(concat([lp],
            [for (th = thetas) lp + Rg*[cos(th), sin(th)]]));
    }
}

// orecchio solido 3D: profilo estruso lungo Y + fori passanti di fissaggio
// lungo v (perni/viti coperchio-orecchio). Nel frame locale l'orecchio occupa
// Y in [-ear_t, 0] e Z = v; i fori passano da sotto il corpo (v = -piv_v-ear_r)
// fino oltre la faccia del tablet (v = t_lid), con eventuale svaso in cima.
module orecchio_solido() {
    difference() {
        estrusa_y(ear_t) profilo_orecchio();
        if (usa_viti_orecchio)
            for (u_i = [vit_u1, vit_u2]) {
                translate([u_i, -ear_t/2, -piv_v - ear_r])
                    cylinder(h = piv_v + ear_r + t_lid + 1, d = vit_foro);
                if (vit_svaso > 0)
                    translate([u_i, -ear_t/2, t_lid - vit_svaso])
                        cylinder(h = vit_svaso + 1, d1 = vit_foro,
                                 d2 = vit_svaso_d);
            }
    }
}

// orecchio in posa: nel riferimento coperchio, fascia Y esterna di ciascun lato
module orecchio_in_posa(t, sy, off_y = 0)
    color("Goldenrod") in_coperchio(t)
        translate([0, sy*Wl/2 + (sy > 0 ? 0 : ear_t) + sy*off_y, 0])
            orecchio_solido();

// ------------------------------- 4. BIELLE ---------------------------------
// Profilo a fessura: inviluppo di due cerchi diametro link_w, fori per i perni.
module biella(L) {
    difference() {
        hull() {
            circle(d = link_w);
            translate([L, 0]) circle(d = link_w);
        }
        circle(d = pin_d + 0.4);
        translate([L, 0]) circle(d = pin_d + 0.4);
    }
}

function ang_biella2(t) = ang_v(P2_posa(t) - B2);

// biella in posa: ruota attorno al perno fisso B_i (angolo dalla sintesi)
module biella_in_posa(tipo, t, sy, off_y = 0) {
    ang = tipo == 1 ? posa_biella1(t) : ang_biella2(t);
    B   = tipo == 1 ? B1 : B2;
    L   = tipo == 1 ? L1 : L2;
    y1  = tipo == 1 ? (sy > 0 ? Yl11 : -Yl10) : (sy > 0 ? Yl21 : -Yl20);
    color("OrangeRed") translate([B[0], y1 + sy*off_y, B[1]])
        rotate([0, -ang, 0]) estrusa_y(link_t) biella(L);
}

// -------------------------------- 5. PERNI ---------------------------------
// Barre da 3 mm (non stampate): mostrate solo nell'assieme.
module perno_sxy(px, pz, sy, ya, yb, off = 0) color("Silver") {
    y0 = sy > 0 ? ya : -yb;                     // inizio (lato interno)
    y1 = sy > 0 ? yb : -ya;                     // fine (lato esterno)
    translate([px, y0 + off, pz])
        rotate([-90, 0, 0]) cylinder(h = y1 - y0, d = pin_d);
}

module perni_in_posa(t, off = 0) {
    yt = Yw1 - foro_prof;                       // fondo del foro cieco
    for (sy = [-1, 1]) {
        P1v = P1_posa(t); P2v = P2_posa(t);
        // B1: parete + orecchio (zona libera) + biella1
        perno_sxy(B1[0], B1[1], sy, yt, Yl11, sy*off);
        // B2: parete + orecchio (zona libera) + biella2
        perno_sxy(B2[0], B2[1], sy, yt, Yl21, sy*off);
        // P1: orecchio + biella1 ; P2: orecchio + biella2
        perno_sxy(P1v[0], P1v[1], sy, Ye0, Yl11, sy*off);
        perno_sxy(P2v[0], P2v[1], sy, Ye0, Yl21, sy*off);
    }
}

// perni stampati (per la prova senza barre): gambo verticale su una
// linguetta di sostegno da staccare; lunghezze identiche al montaggio
module perno_stampato(lung) cylinder(h = lung, d = perno_stamp_d);

module perni_stampa() {
    spes_ling = 0.4;      // spessore linguetta (2 strati a 0.2)
    larg_ling = 4;        // larghezza linguetta
    passo     = 8;        // passo fra i perni
    translate([-passo/2, -larg_ling/2, 0])
        cube([passo*8, larg_ling, spes_ling]);
    // ordine: 2xP1, 2xB1, 2xP2, 2xB2
    for (i = [0:7])
        translate([i*passo, 0, 0])
            perno_stampato(i < 2 ? perno_lung_P1 :
                           i < 4 ? perno_lung_B1 :
                           i < 6 ? perno_lung_P2 : perno_lung_B2);
}

// --------------------------- 6. FANTASMI -----------------------------------
module corpo_tastiera() {
    kc   = 0.25*kb_h;                           // altezza keycap fantasma
    cols = floor(kb_w/18);  pitch = kb_w/cols;  ksz = 0.72*pitch;
    rows = floor(kb_d/18);  rpit  = kb_d/rows;
    translate([wall_f + tol, -kb_w/2, floor_t]) {
        cube([kb_d, kb_w, kb_h - kc]);
        for (i = [0:cols-1], j = [0:rows-1])
            translate([j*rpit + (rpit - ksz)/2, i*pitch + (pitch - ksz)/2,
                       kb_h - kc])
                cube([ksz, ksz, kc]);
    }
}

// --------------------------- MODALITA' DI VISTA ----------------------------
module assieme() {
    color("SteelBlue") base();
    if (porta_aperta) portellino_in_posa();
    coperchio_in_posa(1);
    for (sy = [-1, 1]) orecchio_in_posa(1, sy);
    for (sy = [-1, 1]) biella_in_posa(1, 1, sy);
    for (sy = [-1, 1]) biella_in_posa(2, 1, sy);
    perni_in_posa(1);
}

// layout del piano di stampa
ps_gap         = 25;
ps_x_coperchio = Lu + ps_gap;
ps_x_orecchio  = ps_x_coperchio + Lu + ps_gap;
ps_x_biella1   = ps_x_orecchio + (lp2_u - lp1_u + 2*ear_r) + ps_gap;
ps_x_biella2   = ps_x_biella1 + L1 + ps_gap;
ps_x_porta     = ps_x_biella2 + L2 + ps_gap;
ps_x_perni     = ps_x_porta + (porta_aperta ? porta_l + ps_gap : 0);

// le quattro meta' in assetto di stampa (usate anche come viste/STL singole)
module coperchio_a() translate([ps_x_coperchio, -(Wl/2 + ps_gap), 0])
    color("Peru") meta_coperchio_A();
module coperchio_b() translate([ps_x_coperchio, (Wl/2 + ps_gap), 0])
    color("Chocolate") meta_coperchio_B();
module base_a() translate([0, -(Wt/2 + ps_gap), 0]) color("SteelBlue") meta_base_A();
module base_b() translate([0, (Wt/2 + ps_gap), 0]) color("CornflowerBlue") meta_base_B();

module coperchio_stampa() {
    if (splitta) { coperchio_a(); coperchio_b(); }
    else translate([ps_x_coperchio, 0, 0])
        color("Peru") coperchio_solido();      // faccia posteriore sul letto
}
module base_stampa() {
    if (splitta) { base_a(); base_b(); }
    else color("SteelBlue") base();
}

// vista di controllo della giunzione: base, coperchio e portellino in due
// meta', allontanate per ispezionare denti e predelle
module vista_incastro() {
    espl = 2*ps_gap;                           // allontanamento per l'ispezione
    translate([0, -(Wt/2 + espl), 0]) color("SteelBlue") meta_base_A();
    translate([0, (Wt/2 + espl), 0]) color("CornflowerBlue") meta_base_B();
    translate([ps_x_coperchio, -(Wl/2 + espl), 0]) color("Peru") meta_coperchio_A();
    translate([ps_x_coperchio, (Wl/2 + espl), 0]) color("Chocolate") meta_coperchio_B();
    if (porta_aperta) {
        if (splitta_porta) {
            translate([ps_x_porta, -espl - seam_porta_y, 0]) color("SteelBlue") meta_porta_A();
            translate([ps_x_porta, espl - seam_porta_y, 0]) color("CornflowerBlue") meta_porta_B();
        } else {
            translate([ps_x_porta, -(porta_w - 2*porta_gioco)/2, 0]) color("SteelBlue") portellino();
        }
    }
}
module porta_a() color("SteelBlue")
    translate([ps_x_porta, -ps_gap - seam_porta_y, 0]) meta_porta_A();
module porta_b() color("CornflowerBlue")
    translate([ps_x_porta, ps_gap - seam_porta_y, 0]) meta_porta_B();
module portellino_stampa() {
    if (splitta && splitta_porta) { porta_a(); porta_b(); }
    else color("SteelBlue")
        translate([ps_x_porta, -(porta_w - 2*porta_gioco)/2, 0]) portellino();
}
module orecchio_stampa(sy)
    color("Goldenrod")
        translate([ps_x_orecchio - (lp1_u - ear_r), sy*(ear_t/2 + 10),
                   piv_v + ear_r])
            orecchio_solido();
module biella_stampa(tipo, sy)
    color("OrangeRed")
        translate([tipo == 1 ? ps_x_biella1 : ps_x_biella2,
                   sy*(link_t/2 + 10), link_w/2])
            estrusa_y(link_t) biella(tipo == 1 ? L1 : L2);

module piano_stampa() {
    base_stampa();
    if (porta_aperta) portellino_stampa();
    if (stampa_perni) translate([ps_x_perni, 0, 0]) color("Silver") perni_stampa();
    coperchio_stampa();
    orecchio_stampa(1);
    orecchio_stampa(-1);
    biella_stampa(1, 1);
    biella_stampa(1, -1);
    biella_stampa(2, 1);
    biella_stampa(2, -1);
}

// ------------------------------ ANIMAZIONE ---------------------------------
t_eff = t_manuale > 0 ? min(t_manuale, 1) : $t;
function sstep(x) = let(x = max(0, min(1, x))) x*x*(3 - 2*x);

// frazione di completamento della fase i (1..8) secondo la modalita'
function fase(i) =
    animazione == "assembla" ? (i <= 6 ? sstep(t_eff*6 - (i - 1)) : 0) :
    animazione == "apri"     ? (i <= 6 ? 1 : sstep(t_eff*2 - (i - 7))) :
    sstep(t_eff*8 - (i - 1));

didascalie = [
    "1 - La tastiera si posa nella base",
    "2 - Le orecchie scorrono nelle tasche del coperchio",
    "3 - Il coperchio scende sulla base",
    "4 - Inserimento biella 1",
    "5 - Inserimento biella 2",
    "6 - Inserimento perni da 3 mm",
    "7 - Apertura: il coperchio diventa stand",
    "8 - Il tablet scorre lungo il coperchio fino al fermo"];

function idx_fase() =
    animazione == "assembla" ? min(6, floor(t_eff*6) + 1) :
    animazione == "apri"     ? (t_eff < 0.5 ? 7 : 8) :
    min(8, floor(t_eff*8) + 1);

// didascalia 3D: rivolta alla camera e ancorata in basso nella vista.
// vettore "su dello schermo" della camera gimbal: R(vpr)*[0,1,0] =
// [-cos(rx)*sin(rz), cos(rx)*cos(rz), sin(rx)]. Offset dal centro vista e
// corpo del testo proporzionali a vpd_cam (0.1731 = 0.87*tan(vfov/2) e
// 0.0144 = 18/1250 con vfov 22.5 di default): la didascalia resta al bordo
// inferiore e proporzionata alla vista a qualsiasi scala di camera.
module didascalia(txt) {
    up = [-cos(vpr_cam[0])*sin(vpr_cam[2]),
          cos(vpr_cam[0])*cos(vpr_cam[2]),
          sin(vpr_cam[0])];
    translate(vpt_cam - 0.1731*vpd_cam*up) rotate(vpr_cam)
        linear_extrude(0.002*vpd_cam)
            text(txt, size = 0.0144*vpd_cam, halign = "center", valign = "center");
}

module scena_animata() {
    s1 = fase(1); s2 = fase(2); s3 = fase(3); s4 = fase(4);
    s5 = fase(5); s6 = fase(6); s7 = fase(7); s8 = fase(8);
    // base fissa
    color("SteelBlue") base();
    // fase 1: la tastiera fantasma scende in sede
    translate([0, 0, (1 - s1)*80])
        color([0.85, 0.85, 0.85, 0.55]) corpo_tastiera();
    // fasi 2-3: orecchie laterali nelle tasche, poi il coperchio scende
    alz = (1 - s3)*45;                          // sollevamento iniziale
    if (s2 > 0 || s7 > 0) translate([0, 0, alz]) {
        coperchio_in_posa(s7);
        if (s2 > 0)
            for (sy = [-1, 1]) orecchio_in_posa(s7, sy, (1 - s2)*60);
    }
    // fasi 4-5: bielle che scorrono in senso laterale
    if (s4 > 0) for (sy = [-1, 1]) biella_in_posa(1, s7, sy, (1 - s4)*60);
    if (s5 > 0) for (sy = [-1, 1]) biella_in_posa(2, s7, sy, (1 - s5)*60);
    // fase 6: perni inseriti dall'esterno
    if (s6 > 0) perni_in_posa(s7, (1 - s6)*60);
    // fase 8: tablet fantasma che scorre lungo il coperchio fino al fermo
    if (s8 > 0)
        in_coperchio(1)
            translate([lip_t + (Lu - lip_t)*(1 - s8), -tablet_w/2, t_lid])
                color([0.55, 0.75, 1, 0.45])
                    cube([tablet_h, tablet_w, tablet_t]);
    // didascalia della fase corrente (3D + echo)
    color("Black") didascalia(didascalie[idx_fase() - 1]);
    echo(str("FASE: ", didascalie[idx_fase() - 1]));
}

// ------------------------------- INVOCO ------------------------------------
if (animazione == "nessuna") {
    if      (mostra == "assieme")   assieme();
    else if (mostra == "stampa")    piano_stampa();
    else if (mostra == "base")      base_stampa();
    else if (mostra == "base_a")    base_a();
    else if (mostra == "base_b")    base_b();
    else if (mostra == "coperchio") coperchio_stampa();
    else if (mostra == "coperchio_a") coperchio_a();
    else if (mostra == "coperchio_b") coperchio_b();
    else if (mostra == "porta_a")   porta_a();
    else if (mostra == "porta_b")   porta_b();
    else if (mostra == "incasto")   vista_incastro();
    else if (mostra == "orecchio")  { orecchio_stampa(1); orecchio_stampa(-1); }
    else if (mostra == "biella1")   { biella_stampa(1, 1); biella_stampa(1, -1); }
    else if (mostra == "biella2")   { biella_stampa(2, 1); biella_stampa(2, -1); }
    else if (mostra == "portellino") portellino_stampa();
    else echo(str("Modalita' sconosciuta: ", mostra));
} else {
    scena_animata();
}
