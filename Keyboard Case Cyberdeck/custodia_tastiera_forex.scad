// ============================================================================
//  Custodia per tastiera meccanica con coperchio-stand per tablet
//  VERSIONE FOREX: le facce piane sono PANNELLI di forex (PVC espanso)
//  ---------------------------------------------------------------------------
//  ARCHITETTURA
//  Tutte le facce piane (fondo, 2 pareti laterali, parete frontale, parete
//  posteriore e piastra del coperchio) sono PANNELLI DI FOREX spessi fx_t,
//  tagliati a misura dall'utente (sagomi in mostra="pannelli"). Lo stampato
//  si riduce a INSERTI di raccordo, tutti applicati VERSO L'ESTERNO dei
//  pannelli: dentro la vasca non sporge nulla perche' la tastiera occupa
//  tutto il vano (gioco solo tol).
//    - 2 nervi laterali: pezzo unico per parete, dallo spigolo posteriore a
//      quello frontale, con i fori passanti dei perni B1 e B2 (a cui si
//      agganciano le bielle) e le alette che avvolgono gli spigoli sulle
//      pareti corte
//    - staffe a T sulle pareti frontale/posteriore (rinforzo)
//    - cappe sui bordi superiori (il coperchio vi si appoggia; quelle
//      frontale/posteriore ospitano i magneti)
//    - orecchie, fermo e guide del coperchio: piatti incollati contro i
//      bordi del pannello coperchio
//  La cerniera (quadrilatero articolato, apertura 55 gradi, bielle a gomito)
//  e la cinematica sono identiche alla versione stampata compatta.
//
//  GIUNTI A PERNO f_pin
//  Ogni inserto si POSIZIONA sul pannello con perni da f_pin mm:
//    f_cieco = true  -> MASCHI stampati sull'inserto (lunghezza = spessore
//                       pannello, press-fit nel foro passante del pannello)
//    f_cieco = false -> foro passante anche nell'inserto: BARRE da f_pin mm
//                       tagliate dall'utente (lunghezze negli echo); il
//                       giunto resta smontabile tirando la barra
//  Nel pannello il foro e' passante Ø f_pin + f_pin_g; le posizioni sono
//  nel sagomo (mostra="pannelli"). I perni B2/P1/P2 della cerniera restano
//  barre da pin_d mm (non stampate). Il giunto parete-fondo e' la linea di
//  colla del bordo, vincolata dagli angolari e dalle staffe.
//
//  TELAI LOCALI degli inserti (z=0 = base del pezzo, per la stampa):
//    pezzi a normale Y: y=0 = faccia contro la parete, il pezzo esce in +y
//                       (verso l'esterno); i maschi di posizione vanno in -y
//                       (dentro la parete). In posa si specchia con
//                       scale([1, sy, 1]).
//    pezzi a normale X: x=0 = faccia contro la parete, il pezzo esce in -x
//                       (verso l'esterno); i maschi vanno in +x. In posa sul
//                       retro si specchia con scale([-1, 1, 1]).
//
//  Riferimenti: X = profondita' (fronte->retro), Y = larghezza, Z = altezza.
//  La cinematica e' risolta nel profilo 2D (x, z) ed estrusa lungo Y.
//  Solo OpenSCAD standard, nessuna libreria esterna.
// ============================================================================

/* [Globali] */
$fn  = 32;

/* [Visualizzazione] */
mostra      = "assieme"; // ["assieme","base_assieme","stampa","pannelli","nervo","staffa_fr","cappa_lat","cappa_fr","orecchio","fermo","guida","biella1","biella2"]
animazione  = "nessuna"; // ["nessuna","tutto","assembla","apri"]
t_manuale   = 0;         // >0: forza l'istante dell'animazione (0..1)
camera_auto = true;      // false: disattiva la camera impostata qui

/* [Tastiera] */
kb_w     = 320;   // larghezza tastiera lungo Y [mm]
kb_d     = 124;   // profondita' lungo X [mm]
kb_h     = 32;    // altezza totale, keycap inclusi [mm]
tol      = 0.6;   // gioco tra tastiera e pareti [mm]

/* [Tablet] */
tablet_w = 250;   // larghezza tablet lungo Y [mm]
tablet_h = 175;   // altezza tablet lungo il coperchio [mm]
tablet_t = 8;     // spessore tablet [mm]

/* [Forex (pannelli)] */
fx_t    = 2;      // spessore dei pannelli di forex [mm]
top_gap = 3;      // gioco sopra i keycap a coperchio chiuso [mm]
tasca_prof = 3;   // profondita' degli scassi in cui entra il bordo del pannello [mm]

/* [Perni di posizione] */
f_pin      = 2;   // diametro perni di posizione [mm]
f_pin_g    = 0.2; // gioco del foro nel pannello [mm]
f_cieco    = false; // true = maschi stampati press-fit; false = barre smontabili
f_bar_prof = 6;   // (f_cieco=false) lunghezza barra oltre il pannello [mm]

/* [Cerniera] */
pin_d    = 3;     // diametro perni cerniera (barre da 3 mm) [mm]
link_t   = 4;     // spessore bielle lungo Y [mm]
ear_t    = 4;     // spessore orecchie lungo Y [mm]
g        = 0.6;   // gioco fra livelli adiacenti lungo Y [mm]
link_w   = 12;    // larghezza bielle (profilo a fessura) [mm]
ear_r    = 7;     // raggio dei perni dell'orecchio [mm]
ang_open = 55;    // angolo di apertura [gradi] (a 70 la branca esce dalla vasca)
lp1_u    = 8;     // ascissa locale del perno coperchio P1 [mm]
lp2_u    = 50;    // ascissa locale del perno coperchio P2 [mm]
piv_v    = 12;    // profondita' dei perni sotto la faccia posteriore [mm]
zb1      = 10;    // quota z del perno fisso B1 [mm]
zb2      = 10;    // quota z del perno fisso B2 [mm]

/* [Bielle a gomito] */
bielle_gomito = true; // bielle a gomito (consigliate)
gomito1_f = 0.4;   // posizione gomito biella1 (frazione B->P)
gomito1_e = 6;     // curvatura gomito biella1 (locale +y = giu' a chiuso) [mm]
gomito2_f = 0.5;   // posizione gomito biella2 (frazione B->P)
gomito2_e = -6;    // curvatura gomito biella2 (locale -y = su a chiuso) [mm]

/* [Inserti base] */
leg_t = 4;        // spessore della traversa e delle alette del nervo [mm]
leg_l = 24;       // lunghezza delle alette del nervo sugli spigoli [mm]
leg_h = 14;       // altezza della traversa del nervo [mm]
t_len  = 20;      // lunghezza delle staffe a T [mm]
t_h    = 12;      // altezza delle staffe a T [mm]
ins_t_fr  = [0.3, 0.7];                // posizioni staffe T pareti frontale/posteriore
nervo_tab_fr = [0.09, 0.3, 0.7, 0.91]; // perni del nervo lungo la parete (frazioni)

/* [Cappe superiori] */
cap_t   = 2;      // spessore delle cappe [mm]
cap_h   = 10;     // altezza delle cappe sui bordi delle pareti [mm]
cappe_n = 2;      // segmenti delle cappe frontale/posteriore

/* [Cavi] */
pass_w = 20;      // larghezza fessura cavi nella parete posteriore [mm]
pass_h = 10;      // altezza fessura cavi [mm]

/* [Coperchio (inserti)] */
fermo_t   = 4;    // spessore del fermo del tablet [mm]
fermo_n   = 2;    // segmenti del fermo
fermo_tab = [0.25, 0.75]; // posizioni perni del fermo (frazioni di pannello)
guide_t   = 4;    // altezza/spessore guide laterali tablet [mm]
guide_l   = 45;   // lunghezza delle guide lungo u [mm]
guide_u0  = 4;    // ascissa di inizio guide [mm]
guide_tab = [0.25, 0.75]; // posizioni perni delle guide (frazioni di guida)

/* [Magneti] */
usa_magneti = true; // alloggi nelle cappe frontale/posteriore (1 per segmento)
mag_d  = 4;         // diametro magnete [mm]
mag_h  = 2;         // altezza magnete = profondita' alloggio [mm]
mag_p1 = 0.25;      // posizione 1 lungo Y (frazione di Wi) [-]
mag_p2 = 0.75;      // posizione 2 lungo Y (frazione di Wi) [-]

/* [Accessori] */
foro_prof = 4;    // profondita' fori ciechi perni B (dalla faccia esterna) [mm]
stampa_perni  = false;        // perni cerniera stampati nel piano di stampa
perno_stamp_d = pin_d - 0.1;  // diametro perno stampato (sottodimensionato)

/* [Camera] */
vpr_cam = [62, 0, 215];
vpt_cam = [100, 0, 70];
vpd_cam = 1250;
vpr_lay = [62, 0, 215];
vpt_lay = [82, 84, 0];
vpd_lay = 2800;

// ---------------------- GRANDEZZE DERIVATE --------------------------------
D_kb = kb_d + 2*fx_t;                         // profondita' vano tastiera
Ztop = fx_t + kb_h + top_gap;                 // quota del bordo delle pareti
Wi   = kb_w + 2*tol;                          // larghezza interna
Wt   = Wi + 2*fx_t;                           // larghezza totale (fondo)

// Livelli lungo Y (lato +Y; lato -Y e' speculare)
Yw0  = Wi/2;            // faccia interna parete
Yw1  = Yw0 + fx_t;      // faccia esterna parete (= Wt/2)
Ye0  = Yw1 + g;         // faccia interna orecchio
Ye1  = Ye0 + ear_t;     // faccia esterna orecchio
Yl10 = Ye1 + g;         // faccia interna biella1
Yl11 = Yl10 + link_t;   // faccia esterna biella1
Yl20 = Yl11 + g;        // faccia interna biella2
Yl21 = Yl20 + link_t;   // faccia esterna biella2
Wl   = 2*Ye1;                                 // larghezza totale coperchio

pan_w   = Ye0 + tasca_prof;        // semilarghezza pannello: il bordo entra
                                   // nello scasso dell'orecchio (tasca_prof)
fond_ag = leg_t/2;                 // aggetto del fondo: entra nella scanalatura
                                   // del nervo laterale
h_fermo = tablet_t + 3;            // altezza fermo sopra la faccia tablet
rp_foro = (pin_d + 0.4)/2;         // raggio fori perni cerniera (gioco 0.4)
f_tab_l = fx_t;                    // lunghezza maschi (= spessore pannello)
f_foro  = f_pin + f_pin_g;         // diametro foro nel pannello

// lunghezze perni cerniera (barre da pin_d): B attraverso biella + aria +
// boss/angolare (foro passante) e poggia sulla faccia esterna della parete;
// P attraversano orecchio + biella(e)
perno_lung_B1 = Yl11 - Yw1;             // biella1 + boss B1
perno_lung_B2 = Yl21 - Yw1;             // biella2 + angolare posteriore
perno_lung_P1 = ear_t + g + link_t;             // orecchio + biella1
perno_lung_P2 = ear_t + g + link_t + g + link_t; // orecchio + (aria) + biella2

// posizioni derivate
cap_lat_x0  = lp2_u + ear_r + 2;                 // fine zona orecchie nella cappa
cap_lat_len = D_kb - fx_t;                       // lunghezza cappa laterale
tab_z_hub1 = leg_h*0.3;                          // quote perni nervo (locali)
tab_z_hub2 = leg_h*0.7;
tab_z_t1   = t_h*0.35;                           // quote perni staffe T (locali)
tab_z_t2   = t_h*0.8;
tab_z_cap  = cap_h/2;                            // quota perni cappe (locale)
mag_y1 = (mag_p1 - 0.5)*Wi;                      // posizioni magneti lungo Y
mag_y2 = (mag_p2 - 0.5)*Wi;

assert(lp2_u > lp1_u && piv_v > ear_r,
       str("geometria orecchio non valida:  lp1_u = ", lp1_u, "  lp2_u = ", lp2_u,
           "  piv_v = ", piv_v, "  ear_r = ", ear_r,
           "  (serve lp2_u > lp1_u e piv_v > ear_r)"));
assert(usa_magneti == false || mag_h <= cap_t,
       "magnete piu' spesso dello spessore della cappa: riduci mag_h o aumenta cap_t");
assert(tablet_w/2 + 2*guide_t < pan_w,
       "guide/tablet fuori dal pannello coperchio");
assert(guide_u0 + guide_l < D_kb - 2, "guide oltre il bordo posteriore del coperchio");
assert(f_tab_l <= fx_t + 0.01, "maschio piu' lungo dello spessore del pannello");

vista_layout = mostra != "assieme" && mostra != "base_assieme";

$vpr = camera_auto ? (vista_layout ? vpr_lay : vpr_cam) : [55, 0, 25];
$vpt = camera_auto ? (vista_layout ? vpt_lay : vpt_cam) : [100, 0, 40];
$vpd = camera_auto ? (vista_layout ? vpd_lay : vpd_cam) : 900;

// ------------------ CINEMATICA 2D NEL PIANO (x, z) -------------------------
// Il coperchio vive in un riferimento locale (u, v): u lungo il coperchio a
// partire dal bordo inferiore, v normale alla piastra con v = 0 sulla faccia
// POSTERIORE (quella che guarda la tastiera da chiuso).
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
// aperto: il coperchio si appoggia sullo spigolo superiore della parete
// posteriore della vasca
Oo = [D_kb - fx_t/2, Ztop];

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

// posizioni derivate dalla cinematica + verifiche di ingombro inserti
assert(zb1 - rp_foro - 2 >= fx_t && zb1 + rp_foro + 2 <= fx_t + leg_h,
       "foro B1 fuori dalla traversa del nervo laterale in altezza");
assert(zb2 - rp_foro - 2 >= fx_t && zb2 + rp_foro + 2 <= fx_t + leg_h,
       "foro B2 fuori dalla traversa del nervo laterale in altezza");
assert(B1[0] > leg_t + 2 && B1[0] < D_kb - leg_t - 2,
       "foro B1 fuori dalla traversa del nervo laterale");
assert(B2[0] + rp_foro + 1 <= D_kb && B2[0] - rp_foro - 1 >= 0,
       "foro B2 fuori dalla traversa del nervo laterale");
// i perni del nervo non devono cadere sui fori B1/B2
nervo_tab_bad = [for (f = nervo_tab_fr)
    if (min(abs(f*D_kb - B1[0]), abs(f*D_kb - B2[0])) < 4.5) f];
assert(len(nervo_tab_bad) == 0,
       "perno del nervo sovrapposto a un foro B1/B2: sposta nervo_tab_fr");
// le staffe T sulle pareti corte non devono invadere le alette del nervo
assert(max([for (f = ins_t_fr) abs(-Yw0 + f*Wi)]) + t_len/2 < Yw1 - leg_l - 2,
       "staffa T frontale/posteriore sovrapposta all'aletta del nervo laterale");

// ---------------- VERIFICHE CINEMATICHE A RUNTIME --------------------------
// distanza punto-segmento nel piano
function d_ps(p, a, b) =
    let(ab = b - a, tt = max(0, min(1, dot2(p - a, ab)/dot2(ab, ab))))
    norm(p - (a + tt*ab));
// distanza punto-coperchio (segmento dall'origine, lungo D_kb, alla posa t)
function d_cop(p, t) =
    let(O = O_coperchio(t),
        u = [cos(ang_coperchio(t)), sin(ang_coperchio(t))])
    d_ps(p, O, O + u*D_kb);

// gomiti delle bielle (riferimento mondo, alla posa t)
function E1_posa(t) = B1 + rot2(posa_biella1(t), [gomito1_f*L1, gomito1_e]);
function E2_posa(t) = B2 + rot2(ang_biella2(t),  [gomito2_f*L2, gomito2_e]);

// distanza perno-corpo biella1 (dritta, o a gomito = unione dei due fusi)
function d_biella1(p, t) =
    bielle_gomito ?
        min(d_ps(p, B1, E1_posa(t)), d_ps(p, E1_posa(t), P1_posa(t)),
            norm(p - B1), norm(p - E1_posa(t)), norm(p - P1_posa(t))) - link_w/2
        : d_ps(p, B1, P1_posa(t));

campioni = [for (i = [0:20]) i/20];
min_P2L1  = min([for (t = campioni) d_biella1(P2_posa(t), t)]);
min_B1L2  = min([for (t = campioni) d_ps(B1, B2, P2_posa(t))]);
min_P1L2  = min([for (t = campioni) d_ps(P1_posa(t), B2, P2_posa(t))]);
min_B1cop = min([for (t = campioni) d_cop(B1, t)]);
min_B2cop = min([for (t = campioni) d_cop(B2, t)]);
min_B2L1  = min([for (t = campioni) d_biella1(B2, t)]);
soglia_pin = link_w/2 + rp_foro;
assert(min_P2L1 >= soglia_pin && min_B2L1 >= soglia_pin,
       "perno dentro il corpo della biella1: serve bielle_gomito = true (o un gomito piu' spinto)");
echo(str("VERIFICHE (min su 21 pose):  P2-biella1 = ", min_P2L1, " (>=", soglia_pin, ")  |  ",
         "B1-biella2 = ", min_B1L2, " (>=", soglia_pin, ")  |  P1-biella2 = ", min_P1L2,
         "  |  B1-coperchio = ", min_B1cop, "  |  ",
         "B2-coperchio = ", min_B2cop, "  |  B2-biella1 = ", min_B2L1, " (>=", soglia_pin, ")"));
echo(str("PERNI CERNIERA (2 copie ciascuno, barre da ", pin_d, " mm):  P1 = ",
         perno_lung_P1, "  B1 = ", perno_lung_B1, "  P2 = ", perno_lung_P2,
         "  B2 = ", perno_lung_B2));
echo(str("VERSIONE FOREX (pannelli ", fx_t, " mm):  FONDO = ", Wt + 2*fond_ag,
         " x ", D_kb, " (aggetto ", fond_ag, " mm nei nervi)",
         "  |  PARETI LATERALI = ", D_kb, " x ", Ztop - cap_t - fx_t,
         "  |  FRONTALE/POSTERIORE = ", Wi, " x ", Ztop - cap_t - fx_t,
         " (posteriore con fessura ", pass_w, " x ", pass_h,
         "; pareti accorciate di cap_t: il bordo entra nello scasso delle cappe)",
         "  |  COPERCHIO = ", D_kb, " x ", 2*pan_w,
         ".  Fori nel sagomo: mostra=\"pannelli\"."));
echo(str(f_cieco
    ? str("GIUNTI: maschi stampati Ø", f_pin, " x ", f_tab_l, " (press-fit nel foro Ø", f_foro, ").")
    : str("GIUNTI: barre Ø", f_pin, " -> ", fx_t + f_bar_prof, " mm per angoli/boss/staffe/orecchio/fermo/guida, ",
          fx_t + min(f_bar_prof, cap_t - 0.5), " mm per le cappe; smontabili tirando la barra.")));
echo(str("Attenzione: un tablet di ", tablet_h, " mm sporge oltre il bordo del coperchio."));

// ---------------------------- MODULI COMUNI --------------------------------
// Estrusione lungo Y di un profilo 2D (x = u, y = v): occupa Y in [-h, 0],
// la coordinata y del profilo diventa la quota Z.
module estrusa_y(h) rotate([90, 0, 0]) linear_extrude(height = h) children();

forex_c = [0.82, 0.84, 0.88, 0.65];           // colore "forex" (pannelli)

// giunti di posizione dal piano locale della faccia contro la parete/pannello.
// Convenzione telai: y=0/x=0/z=0 = faccia dell'inserto contro il pannello;
// il pezzo esce VERSO L'ESTERNO (+y per i pezzi a normale Y, -x per quelli a
// normale X, +z per quelli appoggiati) e il pannello sta dall'altro lato.
//   maschio_*: press-fit VERSO il pannello (si uniscono al pezzo)
//   foro_*:    passante ATTRAVERSO il pezzo (si sottraggono al pezzo)
module maschio_y() translate([0, 1, 0]) rotate([90, 0, 0])
    cylinder(h = f_tab_l + 1, d = f_pin);       // 1 mm dentro il pezzo: fusione sicura
module foro_y(h)    rotate([-90, 0, 0]) cylinder(h = h, d = f_foro);
module maschio_x() translate([-1, 0, 0]) rotate([0, 90, 0])
    cylinder(h = f_tab_l + 1, d = f_pin);
module foro_x(h)    rotate([0, -90, 0]) cylinder(h = h, d = f_foro);
module maschio_z() translate([0, 0, 1]) rotate([180, 0, 0])
    cylinder(h = f_tab_l + 1, d = f_pin);
module maschio_xm() translate([1, 0, 0]) rotate([0, -90, 0])
    cylinder(h = f_tab_l + 1, d = f_pin);      // verso -x (parete oltre il telao)
module foro_xm(h)   rotate([0, 90, 0]) cylinder(h = h, d = f_foro);
module foro_z(h)    cylinder(h = h, d = f_foro);

// ---------------------- PANNELLI DI FOREX (SAGOMI) -------------------------
// Sagomi 2D con i fori di posizione gia' tagliati: stampabili e usabili come
// maschere di trapanatura sul forex. I fori "a bordo" (orecchio/fermo) sono
// segni di posizione: nel reale si fora il BORDO del pannello in orizzontale.

// 1. FONDO: aggetto di fond_ag per lato: il bordo entra nella scanalatura
//    del nervo laterale (pareti laterali); i bordi frontale/posteriore sono
//    catturati dai labbri a filo fondo di nervo (alette) e staffe
module sagomo_fondo() square([D_kb, Wt + 2*fond_ag]);

// 2. PARETE LATERALE (nel piano x, z con z' = z - fx_t): altezza ridotta di
// cap_t perche' il bordo entri nello scasso della cappa; il ponte della cappa
// riporta il sostegno del coperchio a filo (Ztop).
// I perni B1/B2 della cerniera non forano la parete: passano solo nel nervo.
module sagomo_parete_lat() {
    dh = Ztop - cap_t - fx_t;
    difference() {
        square([D_kb, dh]);
        // nervo laterale: fori lungo la traversa (alternati alto/basso)
        for (i = [0:len(nervo_tab_fr)-1])
            translate([nervo_tab_fr[i]*D_kb,
                       (i % 2 == 0 ? tab_z_hub1 : tab_z_hub2) - fx_t])
                circle(d = f_foro);
        // cappa laterale: 2 fori
        for (fr = [0.25, 0.75])
            translate([cap_lat_x0 + (cap_lat_len - cap_lat_x0)*fr,
                       dh + cap_t - cap_h + tab_z_cap])
                circle(d = f_foro);
    }
}

// 3. PARETE FRONTALE/POSTERIORE (nel piano y, z con z' = z - fx_t):
// altezza ridotta di cap_t per lo scasso delle cappe.
module sagomo_parete_fr(retro) {
    dh = Ztop - cap_t - fx_t;
    difference() {
        square([Wi, dh]);
        // alette del nervo laterale su questa parete (entrambi gli spigoli):
        // abbinamento (vicino allo spigolo, basso) / (piu' dentro, alto)
        for (sx = [-1, 1],
             pr = [[Yw1 - 8, tab_z_hub1 - fx_t], [Yw1 - 20, tab_z_hub2 - fx_t]])
            translate([Wi/2 + sx*pr[0], pr[1]]) circle(d = f_foro);
        // staffe a T
        for (f = ins_t_fr,
             pr = [[-t_len*0.25, tab_z_t1 - fx_t], [t_len*0.25, tab_z_t2 - fx_t]])
            translate([f*Wi + pr[0], pr[1]]) circle(d = f_foro);
        // cappe frontale/posteriore: 2 fori per segmento
        for (i = [0:cappe_n - 1], fr = [0.25, 0.75])
            translate([i*Wi/cappe_n + fr*Wi/cappe_n,
                       dh + cap_t - cap_h + tab_z_cap])
                circle(d = f_foro);
        if (retro)
            // fessura cavi: da tagliare nel pannello
            translate([Wi/2 - pass_w/2, 0]) square([pass_w, pass_h]);
    }
}

// 4. PANNELLO COPERCHIO (nel piano u, y con y' = y + pan_w): il pannello
//    sporge di tasca_prof in avanti (bordo nello scasso del fermo) e per
//    lato (bordo negli scassi delle orecchie).
//    fori VERTICALI tagliati (guide); i segni sui bordi indicano le posizioni
//    di orecchie e fermo (lì il bordo entra nei loro scassi).
module sagomo_coperchio() {
    difference() {
        translate([-tasca_prof, 0])
            square([D_kb + tasca_prof, 2*pan_w]);
        // guide: fori passanti verticali
        for (sy = [-1, 1], fr = guide_tab)
            translate([guide_u0 + fr*guide_l,
                       pan_w + sy*(tablet_w/2 + 1.5*guide_t)])
                circle(d = f_foro);
        // segni estremita' scasso orecchie (sul bordo laterale)
        for (sy = [0, 2*pan_w], uu = [lp1_u, lp2_u])
            translate([uu, sy]) circle(d = f_foro);
        // segni bocca scasso fermo (sul bordo frontale)
        for (sy = [-1, 1], fr = fermo_tab)
            translate([0, pan_w + sy*pan_w*fr]) circle(d = f_foro);
    }
}

// ------------------- INSERTI STAMPATI (telai locali) -----------------------
// Telai locali: z=0 = base del pezzo; y=0 (o x=0) = faccia contro la parete;
// il pezzo esce VERSO L'ESTERNO (+y per i pezzi a normale Y, -x per quelli a
// normale X); i maschi di posizione puntano VERSO la parete.

// 1. NERVO LATERALE: pezzo unico per parete laterale, dallo spigolo
//    posteriore a quello frontale. Ospita i FORI PASSANTI dei perni B1 e B2
//    (a cui si agganciano le bielle) e due alette che avvolgono gli spigoli
//    sulle facce esterne delle pareti frontale e posteriore.
//    Telao: x=0 allo spigolo FRONTALE, +x verso il retro; y=0 = faccia contro
//    la parete (il pezzo esce in +y, verso l'esterno).
module nervo_laterale_pezzo() {
    difference() {
        union() {
            // traversa lungo tutta la parete laterale
            cube([D_kb, leg_t, leg_h]);
            // aletta posteriore (sulla faccia esterna della parete posteriore)
            translate([D_kb, -leg_l, 0]) cube([leg_t, leg_l + leg_t, leg_h]);
            // aletta frontale (sulla faccia esterna della parete frontale)
            translate([-leg_t, -leg_l, 0]) cube([leg_t, leg_l + leg_t, leg_h]);
            if (f_cieco) {
                // perni lungo la traversa (z alternati alto/basso)
                for (i = [0:len(nervo_tab_fr)-1])
                    translate([nervo_tab_fr[i]*D_kb, 0,
                               i % 2 == 0 ? tab_z_hub1 : tab_z_hub2])
                        maschio_y();
                // aletta frontale: maschi verso +x (nel pannello frontale)
                for (i = [0, 1])
                    translate([0, -(8 + 12*i),
                               i == 0 ? tab_z_hub1 : tab_z_hub2])
                        maschio_x();
                // aletta posteriore: maschi verso -x (nel pannello posteriore)
                for (i = [0, 1])
                    translate([D_kb, -(8 + 12*i),
                               i == 0 ? tab_z_hub1 : tab_z_hub2])
                        maschio_xm();
            }
        }
        // scanalatura a filo fondo lungo tutta la traversa: il bordo
        // laterale del pannello fondo (aggetto fond_ag) vi scorre dentro
        translate([0, 0, -0.1])
            cube([D_kb, fond_ag, fx_t + g + 0.2]);
        // fori passanti dei perni B1 e B2 della cerniera
        for (i = [0, 1])
            translate([(i == 0 ? B1 : B2)[0], 0, (i == 0 ? zb1 : zb2)])
                rotate([90, 0, 0])
                    cylinder(h = 2*leg_t + 4, d = pin_d + 0.4, center = true);
        if (!f_cieco) {
            for (i = [0:len(nervo_tab_fr)-1])
                translate([nervo_tab_fr[i]*D_kb, 0,
                           i % 2 == 0 ? tab_z_hub1 : tab_z_hub2])
                    foro_y(leg_t + 1);
            for (i = [0, 1]) {
                translate([0, -(8 + 12*i), i == 0 ? tab_z_hub1 : tab_z_hub2])
                    foro_x(leg_t + 1);
                translate([D_kb, -(8 + 12*i), i == 0 ? tab_z_hub1 : tab_z_hub2])
                    foro_xm(leg_t + 1);
            }
        }
    }
}
module staffa_fr_pezzo() {                    // pareti frontale/posteriore
    difference() {
        union() {
            translate([-cap_t, -t_len/2, 0]) cube([cap_t, t_len, t_h]);
            if (f_cieco)
                for (i = [0, 1])
                    translate([0, (i == 0 ? -t_len*0.25 : t_len*0.25),
                               i == 0 ? tab_z_t1 : tab_z_t2])
                        maschio_x();
        }
        if (!f_cieco)
            for (i = [0, 1])
                translate([0, (i == 0 ? -t_len*0.25 : t_len*0.25),
                           i == 0 ? tab_z_t1 : tab_z_t2])
                    foro_x(cap_t + 1);
    }
}

// 4. CAPPE = SELLHE DI INCASTRO sul bordo superiore delle pareti: il pannello
//    (accorciato di cap_t) scorre dentro lo scasso; il ponte e' a filo del
//    bordo (Ztop) e il coperchio vi appoggia come prima.
module cappa_lat_pezzo() {                    // pareti laterali
    x0 = cap_lat_x0;                          // fine zona orecchie
    L  = cap_lat_len - x0;                    // lunghezza sella completa
    difference() {
        union() {
            // ponte stretto sulla zona orecchie (la gamba esterna invaderebbe
            // le orecchie a coperchio chiuso)
            translate([0, -fx_t - g/2, cap_h - cap_t])
                cube([x0, fx_t + g/2 + 0.55, cap_t]);
            // ponte largo + gamba esterna oltre le orecchie
            translate([x0, -fx_t - g/2, cap_h - cap_t])
                cube([L, fx_t + g + cap_t, cap_t]);
            translate([x0, g/2, 0])
                cube([L, cap_t, cap_h - cap_t]);
            if (f_cieco)
                for (fr = [0.25, 0.75])
                    translate([x0 + L*fr, g/2, tab_z_cap]) maschio_y();
        }
        if (!f_cieco)
            for (fr = [0.25, 0.75])
                translate([x0 + L*fr, g/2, tab_z_cap]) foro_y(cap_t + 1);
    }
}
module cappa_fr_pezzo(mag_ly = mag_y1 + Wi/2) {   // frontale/posteriore
    seg_w = Wi/cappe_n;
    difference() {
        union() {
            difference() {
                union() {
                    // ponte a filo del bordo: lo scasso riceve il pannello
                    // (ristretto di 2.7 mm all'estremita' esterna per non
                    // invadere il ponte stretto del nervo all'angolo)
                    translate([-g/2, 0.5, cap_h - cap_t])
                        cube([fx_t + g, seg_w - 2.7, cap_t]);
                    // piastra esterna (fusa al ponte)
                    translate([-cap_t - g/2, 0, 0])
                        cube([cap_t, seg_w, cap_h - cap_t + 0.5]);
                    if (usa_magneti)
                        translate([-cap_t/2 - g/2, mag_ly,
                                   cap_h - cap_t - mag_h])
                            cylinder(h = mag_h + 1, d = mag_d);
                }
            }
            if (f_cieco)
                for (fr = [0.25, 0.75])
                    translate([-g/2, seg_w*fr, tab_z_cap]) maschio_x();
        }
        if (!f_cieco)
            for (fr = [0.25, 0.75])
                translate([-g/2, seg_w*fr, tab_z_cap]) foro_x(cap_t + 1);
    }
}

// 5. ORECCHIO (piatto contro il bordo laterale del pannello coperchio)
// Telao: y=0 = faccia contro il bordo del pannello, il pezzo esce in +y;
// profilo 2D nel riferimento del coperchio (u, v), perni P1/P2 a v = -piv_v.
module profilo_orecchio() {
    difference() {
        union() {
            hull() {
                translate(lp1) circle(r = ear_r);
                translate(lp2) circle(r = ear_r);
            }
            // pala contro il bordo del pannello, con il labbro superiore che
            // chiude lo scasso (v fino a fx_t + g + 2)
            translate([lp1_u, -(piv_v + ear_r)])
                square([lp2_u - lp1_u, piv_v + ear_r + fx_t + g + 2]);
        }
        // fori dei perni P1/P2 (orecchio <-> bielle)
        for (lp = [lp1, lp2]) translate(lp) circle(d = pin_d + 0.4);
        // zona libera per i perni B1/B2 (spazzata durante l'apertura)
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

// orecchio solido 3D: profilo estruso lungo Y + SCASSO in cui scorre il
// bordo laterale del pannello coperchio (lungo u, con labbro di chiusura in
// alto collegato dal fondo dello scasso).
module orecchio_pezzo() {
    difference() {
        translate([0, ear_t, 0]) estrusa_y(ear_t) profilo_orecchio();
        // scasso: il bordo del pannello (spessore fx_t + gioco) entra dalla
        // parte interna e scorre lungo u; dietro resta tasca_prof di materia
        translate([lp1_u - 1, 0, -0.1])
            cube([lp2_u - lp1_u + 2, tasca_prof, fx_t + g + 0.2]);
    }
}

// 6. FERMO del tablet (piatto contro il bordo frontale del pannello coperchio)
// Telao: x=0 = faccia contro il bordo del pannello (il pannello sta in x>0);
// il fermo esce in -x (fuori dal case) e sale fino a fx_t + h_fermo.
// SCASSO: il bordo frontale del pannello scorre dentro (lungo y), trattenuto
// dal labbro superiore a v = fx_t + g.
module fermo_pezzo() {
    seg_fw = 2*pan_w/fermo_n;
    difference() {
        translate([-fermo_t, 0, 0]) cube([fermo_t, seg_fw, fx_t + h_fermo]);
        // scasso lungo tutto il segmento (aperto ai lati y)
        translate([-tasca_prof, -1, -0.1])
            cube([tasca_prof + 0.1, seg_fw + 2, fx_t + g + 0.2]);
    }
}

// 7. GUIDA laterale del tablet (piatto sulla faccia tablet del pannello)
// Telao: z=0 = faccia sul pannello; il maschio va nel pannello (-z).
module guida_pezzo() {
    difference() {
        union() {
            cube([guide_l, guide_t, guide_t]);
            if (f_cieco)
                for (fr = guide_tab)
                    translate([guide_l*fr, guide_t/2, 0]) maschio_z();
        }
        if (!f_cieco)
            for (fr = guide_tab)
                translate([guide_l*fr, guide_t/2, 0]) foro_z(guide_t + 1);
    }
}

// ------------------------------- 8. BIELLE ---------------------------------
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

// Biella a GOMITO: unione NON convessa di due fusi B->gomito e gomito->P.
// Il corpo scivola oltre i perni P2/B1 dell'altra biella (gomito1: verso il
// basso a cerniera chiusa; gomito2: verso l'alto). e > 0 piega verso +y locale.
module biella_gomito(L, f, e) {
    difference() {
        union() {
            hull() {
                circle(d = link_w);
                translate([f*L, e]) circle(d = link_w);
            }
            hull() {
                translate([f*L, e]) circle(d = link_w);
                translate([L, 0]) circle(d = link_w);
            }
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
        rotate([0, -ang, 0]) estrusa_y(link_t)
            if (bielle_gomito)
                biella_gomito(L, tipo == 1 ? gomito1_f : gomito2_f,
                                 tipo == 1 ? gomito1_e : gomito2_e);
            else
                biella(L);
}

// ------------------------------- 9. PERNI ----------------------------------
// Barre da pin_d mm (non stampate): mostrate solo nell'assieme.
module perno_sxy(px, pz, sy, ya, yb, off = 0) color("Silver") {
    y0 = sy > 0 ? ya : -yb;                     // inizio (lato interno)
    y1 = sy > 0 ? yb : -ya;                     // fine (lato esterno)
    translate([px, y0 + off, pz])
        rotate([-90, 0, 0]) cylinder(h = y1 - y0, d = pin_d);
}

module perni_in_posa(t, off = 0) {
    for (sy = [-1, 1]) {
        P1v = P1_posa(t); P2v = P2_posa(t);
        // B1: boss (passante) + zona libera + biella1
        perno_sxy(B1[0], B1[1], sy, Yw1, Yl11, sy*off);
        // B2: angolare posteriore (passante) + zona libera + biella2
        perno_sxy(B2[0], B2[1], sy, Yw1, Yl21, sy*off);
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

// --------------------------- 10. FANTASMI ----------------------------------
module corpo_tastiera() {
    kc   = 0.25*kb_h;                           // altezza keycap fantasma
    cols = floor(kb_w/18);  pitch = kb_w/cols;  ksz = 0.72*pitch;
    rows = floor(kb_d/18);  rpit  = kb_d/rows;
    translate([fx_t + tol, -kb_w/2, fx_t]) {
        cube([kb_d, kb_w, kb_h - kc]);
        for (i = [0:cols-1], j = [0:rows-1])
            translate([j*rpit + (rpit - ksz)/2, i*pitch + (pitch - ksz)/2,
                       kb_h - kc])
                cube([ksz, ksz, kc]);
    }
}

// ---------------------- PANNELLI IN POSA (forex) ---------------------------
module pannelli_base_in_posa() {
    color(forex_c) translate([0, -(Wt + 2*fond_ag)/2, 0])
        cube([D_kb, Wt + 2*fond_ag, fx_t]);                               // fondo
    for (sy = [-1, 1]) color(forex_c)
        translate([0, sy > 0 ? Yw0 : -Yw1, fx_t])
            cube([D_kb, fx_t, Ztop - cap_t - fx_t]);                      // laterali
    color(forex_c) translate([0, -Yw0, fx_t])
        cube([fx_t, Wi, Ztop - cap_t - fx_t]);                            // frontale
    color(forex_c) difference() {
        translate([D_kb - fx_t, -Yw0, fx_t])
            cube([fx_t, Wi, Ztop - cap_t - fx_t]);                        // posteriore
        translate([D_kb - fx_t - 1, -pass_w/2, fx_t])
            cube([fx_t + 2, pass_w, pass_h]);                             // fessura
    }
}

// pannello coperchio nel riferimento locale del coperchio (u, v):
// sporge di tasca_prof oltre il fronte (il bordo entra nello scasso del fermo)
// e di tasca_prof per lato (il bordo entra negli scassi delle orecchie)
module coperchio_pannello() color(forex_c)
    translate([-tasca_prof, -pan_w, 0])
        cube([D_kb + tasca_prof, 2*pan_w, fx_t]);

// -------------------------- INSERTI IN POSA --------------------------------
module inserti_base_in_posa() {
    for (sy = [-1, 1]) {
        translate([0, sy*Yw1, 0]) scale([1, sy, 1])
            color("SteelBlue") nervo_laterale_pezzo();
        //translate([0, sy*Yw1, Ztop - cap_h]) scale([1, sy, 1])
        //    color("LightSlateGray") cappa_lat_pezzo();
    }
    for (f = ins_t_fr) {
        translate([0, -Yw0 + f*Wi, 0]) color("Teal") staffa_fr_pezzo();
        translate([D_kb, -Yw0 + f*Wi, 0]) scale([-1, 1, 1]) color("Teal") staffa_fr_pezzo();
    }
    for (i = [0:cappe_n - 1]) {
        translate([0, -Yw0 + i*Wi/cappe_n, Ztop - cap_h])
            color("LightSlateGray") cappa_fr_pezzo();
        translate([D_kb, -Yw0 + i*Wi/cappe_n, Ztop - cap_h])
            scale([-1, 1, 1]) color("LightSlateGray") cappa_fr_pezzo();
    }
}

// applica la posa t del coperchio ai figli (costruiti nel riferimento locale)
module in_coperchio(t)
    translate([O_coperchio(t)[0], 0, O_coperchio(t)[1]])
        rotate([0, -ang_coperchio(t), 0]) children();

// coperchio montato: pannello forex + fermo + guide (le orecchie a parte)
module coperchio_in_posa(t) in_coperchio(t) {
    coperchio_pannello();
    color("Peru")
        for (i = [0:fermo_n - 1])
            translate([0, -pan_w + i*2*pan_w/fermo_n, 0]) fermo_pezzo();
    color("Peru")
        for (sy = [-1, 1])
            translate([guide_u0, sy*(tablet_w/2 + guide_t), fx_t])
                scale([1, sy, 1]) guida_pezzo();
}

// orecchio in posa: contro il bordo laterale del pannello coperchio
module orecchio_in_posa(t, sy, off_y = 0)
    color("Goldenrod") in_coperchio(t)
        translate([0, sy*(Ye0 + off_y), 0]) scale([1, sy, 1]) orecchio_pezzo();

// --------------------------- MODALITA' DI VISTA ----------------------------
module assieme() {
    pannelli_base_in_posa();
    inserti_base_in_posa();
    coperchio_in_posa(1);
    for (sy = [-1, 1]) orecchio_in_posa(1, sy);
    for (sy = [-1, 1]) { biella_in_posa(1, 1, sy); biella_in_posa(2, 1, sy); }
    perni_in_posa(1);
}

// orecchio in assetto di stampa (profilo con il punto piu' basso sul letto)
module orecchio_stampa_p() translate([0, 0, piv_v + ear_r]) orecchio_pezzo();

// layout del piano di stampa: fasce separate con gioco >= 2 mm fra pezzi
// (ingombri calcolati INCLUSE le sporgenze dei maschi di posizione) per
// consentire la separazione in oggetti distinti nello slicer
module biella_stampa(tipo, px, py) color("OrangeRed")
    translate([px, py, link_w/2]) estrusa_y(link_t)
        if (bielle_gomito)
            biella_gomito(tipo == 1 ? L1 : L2,
                          tipo == 1 ? gomito1_f : gomito2_f,
                          tipo == 1 ? gomito1_e : gomito2_e);
        else
            biella(tipo == 1 ? L1 : L2);

module piano_stampa() {
    // riga 1: pezzi lunghi ruotati (cappe fr + fermo): x 0..163, y 2.1..42
    for (k = [0:2*cappe_n-1])
        translate([0, 2.2 + 7*k, 0]) rotate([0, 0, -90]) cappa_fr_pezzo();
    translate([0, 30, 0]) rotate([0, 0, -90]) fermo_pezzo();
    translate([0, 38, 0]) rotate([0, 0, -90]) fermo_pezzo();
    // nervi laterali (2): pezzo unico lungo la parete (x -4..132, y -24..4)
    translate([4, 68, 0])  nervo_laterale_pezzo();  // x 0..136, y 44..72
    translate([4, 85, 0]) scale([1, -1, 1]) nervo_laterale_pezzo();  // y 80..108
    // cappe laterali (2) e orecchie (2)
    translate([4, 116, 0]) cappa_lat_pezzo();     // x 4..130, y 113.7..118.3
    translate([4, 124, 0]) cappa_lat_pezzo();     // y 121.7..126.3
    translate([4, 134, 0]) orecchio_stampa_p();   // x 5..61, y 134..138
    translate([4, 142, 0]) orecchio_stampa_p();   // y 142..146
    // guide (2)
    translate([76, 134, 0]) guida_pezzo();        // x 76..121, y 134..138
    translate([76, 142, 0]) guida_pezzo();        // y 142..146
    // staffe T frontali/posteriori (4)
    translate([2, 158, 0])  staffa_fr_pezzo();    // x -0.3..1.7, y 148..168
    translate([8, 158, 0])  staffa_fr_pezzo();
    translate([2, 182, 0])  staffa_fr_pezzo();    // y 172..192
    translate([8, 182, 0])  staffa_fr_pezzo();
    // bielle (4) ruotate in colonna a destra
    translate([144, 146, 0]) rotate([0, 0, -90]) biella_stampa(1, 0, 0);  // x 140..144, y 70..152
    translate([150, 146, 0]) rotate([0, 0, -90]) biella_stampa(1, 0, 0);
    translate([156, 150, 0]) rotate([0, 0, -90]) biella_stampa(2, 0, 0);  // x 152..156, y 72..158
    translate([162, 150, 0]) rotate([0, 0, -90]) biella_stampa(2, 0, 0);
    // perni della cerniera (opzione)
    if (stampa_perni) translate([30, 178, 0]) color("Silver") perni_stampa();
}

// vista dei sagomi forex (da ritagliare)
module pannelli_vista() {
    color(forex_c) sagomo_fondo();                                   // fondo
    color(forex_c) translate([D_kb + 20, 0, 0]) sagomo_parete_lat();  // laterale
    color(forex_c) translate([D_kb + 20, Ztop + 8, 0]) sagomo_parete_fr(false);
    color(forex_c) translate([D_kb + 20, Ztop + 8 + Ztop, 0]) sagomo_parete_fr(true);
    color(forex_c) translate([0, Wt + 20, 0]) sagomo_coperchio();
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
    "1 - La tastiera si posa nel fondo forex",
    "2 - Le orecchie si applicano ai bordi del pannello",
    "3 - Il pannello coperchio scende sulla base",
    "4 - Inserimento biella 1",
    "5 - Inserimento biella 2",
    "6 - Inserimento perni da 3 mm",
    "7 - Apertura: il coperchio diventa stand",
    "8 - Il tablet scorre lungo il pannello fino al fermo"];

function idx_fase() =
    animazione == "assembla" ? min(6, floor(t_eff*6) + 1) :
    animazione == "apri"     ? (t_eff < 0.5 ? 7 : 8) :
    min(8, floor(t_eff*8) + 1);

// didascalia 3D: rivolta alla camera e ancorata in basso nella vista.
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
    pannelli_base_in_posa();
    inserti_base_in_posa();
    // fase 1: la tastiera fantasma scende in sede
    translate([0, 0, (1 - s1)*80])
        color([0.85, 0.85, 0.85, 0.55]) corpo_tastiera();
    // fasi 2-3: orecchie laterali sui bordi, poi il pannello scende
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
    // fase 8: tablet fantasma che scorre lungo il pannello fino al fermo
    if (s8 > 0)
        in_coperchio(1)
            translate([D_kb*(1 - s8), -tablet_w/2, fx_t])
                color([0.55, 0.75, 1, 0.45])
                    cube([tablet_h, tablet_w, tablet_t]);
    // didascalia della fase corrente (3D + echo)
    color("Black") didascalia(didascalie[idx_fase() - 1]);
    echo(str("FASE: ", didascalie[idx_fase() - 1]));
}

// ------------------------------- INVOCO ------------------------------------
if (animazione == "nessuna") {
    if      (mostra == "assieme")      assieme();
    else if (mostra == "base_assieme") { pannelli_base_in_posa(); inserti_base_in_posa(); }
    else if (mostra == "stampa")       piano_stampa();
    else if (mostra == "pannelli")     pannelli_vista();
    else if (mostra == "nervo")      { nervo_laterale_pezzo(); translate([0, 32, 0]) nervo_laterale_pezzo(); }
    else if (mostra == "staffa_fr")  for (k = [0:len(ins_t_fr)-1]) {
                                         translate([k*8, 0, 0])  staffa_fr_pezzo();
                                         translate([k*8, -24, 0]) staffa_fr_pezzo(); }
    else if (mostra == "cappa_lat")  { cappa_lat_pezzo(); translate([cap_lat_len + 8, 0, 0]) cappa_lat_pezzo(); }
    else if (mostra == "cappa_fr")     { cappa_fr_pezzo(); translate([8, -8, 0]) cappa_fr_pezzo(); }
    else if (mostra == "orecchio")     { orecchio_stampa_p(); translate([64, 0, 0]) orecchio_stampa_p(); }
    else if (mostra == "fermo")        for (i = [0:fermo_n-1])
                                           translate([i*(2*pan_w/fermo_n + 6), 0, 0]) fermo_pezzo();
    else if (mostra == "guida")        { guida_pezzo(); translate([guide_l + 8, 0, 0]) guida_pezzo(); }
    else if (mostra == "biella1")      { biella_stampa(1, 0, 0); translate([L1 + 12, 0, 0]) biella_stampa(1, 0, 0); }
    else if (mostra == "biella2")      { biella_stampa(2, 0, 0); translate([L2 + 12, 0, 0]) biella_stampa(2, 0, 0); }
    else echo(str("Modalita' sconosciuta: ", mostra));
} else {
    scena_animata();
}
