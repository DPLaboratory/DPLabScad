// ============================================================
// Basi rotonde per miniature - parametriche
// Superfici: liscia, mattoni (anche irregolari), ciottoli, sterrato,
//            assi di legno, lastre di pietra
// ============================================================

/* [Base] */
// Diametro in mm (25, 28.5, 32, 40, 50, 60...)
diametro = 32;
altezza = 3.5;
// Smusso sul bordo superiore (45 gradi)
smusso_alto = 1.0;
// Smusso sul bordo inferiore
smusso_basso = 0.4;
// Anello esterno liscio, non texturizzato (0 = nessuno)
bordo_liscio = 0;
// Alloggiamento magnete sotto la base (0 = nessuno)
diametro_magnete = 0;
altezza_magnete = 2;

/* [Superficie] */
superficie = "mattoni"; // [liscia, mattoni, ciottoli, sterrato, assi, lastre]
// Profondità della texture in mm
profondita = 0.8;
// Rotazione del disegno della texture
angolo_texture = 0;
// Cambia il seed per ottenere una variante diversa
seed = 7;

/* [Mattoni] */
mattone_l = 5;
mattone_w = 2.5;
// Larghezza dei giunti
malta = 0.5;
// 0 = mattoni regolari, 0.5 = lunghezze molto irregolari (max 0.9)
variazione = 0.0;

/* [Ciottoli] */
// Dimensione media di un ciottolo (passo della griglia)
cella = 4;
// Quanto i ciottoli sono spostati dalla griglia (0..1)
disordine = 0.35;
// Quanto i ciottoli riempiono la cella (0.8..1.1)
riempimento = 0.95;

/* [Sterrato] */
// Sassolini per mm quadrato
densita = 0.5;
sasso_min = 0.3;
sasso_max = 1.2;

/* [Assi di legno] */
// Larghezza media delle assi
assi_w = 3;
// Lunghezza media delle assi
assi_l = 12;
// Fessura tra le assi
fessura = 0.4;
// 0 = assi regolari, 0.4 = molto irregolari (max 0.5)
irregolarita_assi = 0.2;
// Ogni asse viene abbassata di un valore casuale fino a questo (mm)
dislivello_assi = 0.15;
// Venature incise per asse (0 = nessuna)
venature = 1;
vena_larghezza = 0.25;
vena_profondita = 0.2;

/* [Lastre di pietra] */
// Dimensione media di una lastra
lastre_dim = 8;
// Irregolarità della forma (0..0.8)
lastre_disordine = 0.6;
// Larghezza delle fughe
fuga = 0.6;
// Smusso sul bordo superiore delle lastre
lastre_smusso = 0.25;
// Ogni lastra viene abbassata di un valore casuale fino a questo (mm)
lastre_dislivello = 0.3;
// Arrotondamento degli angoli
lastre_raggio = 0.6;

// ------------------------------------------------------------
R = diametro / 2;
H = altezza;
D = profondita;
Rin = R - bordo_liscio;

assert(H > smusso_alto + smusso_basso, "Altezza troppo bassa per gli smussi");
assert(D < H - smusso_basso, "Profondità texture troppo grande");
assert(variazione >= 0 && variazione < 0.9, "variazione deve stare tra 0 e 0.9");
assert(diametro_magnete == 0 || altezza_magnete < H - 0.6, "Magnete troppo alto");
assert(irregolarita_assi >= 0 && irregolarita_assi < 0.5, "irregolarita_assi deve stare tra 0 e 0.5");
assert(superficie != "assi" || dislivello_assi < D, "dislivello_assi deve essere minore della profondita");
assert(superficie != "lastre" || lastre_dislivello + lastre_smusso < D, "lastre_dislivello + lastre_smusso devono essere minori della profondita");
assert(lastre_dim > 2 * fuga, "lastre_dim troppo piccolo rispetto alla fuga");

// Corpo base con smussi
module corpo() {
    rotate_extrude($fn = 128)
        polygon([[0, 0], [R - smusso_basso, 0], [R, smusso_basso],
                 [R, H - smusso_alto], [R - smusso_alto, H], [0, H]]);
}

function cumsum(v, i = 0, s = 0) =
    i >= len(v) ? [] : concat([s + v[i]], cumsum(v, i + 1, s + v[i]));

// Giunti di malta da sottrarre dalla superficie
module solchi_mattoni() {
    passo_y = mattone_w + malta;
    righe = ceil(R / passo_y) + 1;
    for (j = [-righe : righe - 1]) {
        y0 = j * passo_y;
        n = ceil(2 * R / (mattone_l * (1 - variazione) + malta)) + 3;
        rv = rands(-1, 1, n, seed + j + 1000);
        xs = cumsum([for (k = [0 : n - 1]) mattone_l * (1 + variazione * rv[k]) + malta]);
        x0 = -R - mattone_l * ((j % 2 == 0) ? 0.25 : 0.75);
        // giunto orizzontale
        translate([-R - 1, y0 - malta / 2, H - D])
            cube([2 * R + 2, malta, D + 1]);
        // giunti verticali sfalsati
        for (x = xs)
            translate([x0 + x - malta / 2, y0, H - D])
                cube([malta, passo_y, D + 1]);
    }
}

// Selciato irregolare: cupole ellittiche su griglia sfalsata e disturbata
module ciottoli() {
    nn = ceil(2 * R / cella) + 3;
    rv = rands(0, 1, nn * nn * 6, seed);
    for (i = [0 : nn - 1], j = [0 : nn - 1]) {
        k = (i * nn + j) * 6;
        sfalsa = (j % 2 == 0) ? 0 : cella / 2;
        cx = (i - (nn - 1) / 2) * cella + sfalsa + (rv[k] - 0.5) * cella * disordine;
        cy = (j - (nn - 1) / 2) * cella + (rv[k + 1] - 0.5) * cella * disordine;
        if (norm([cx, cy]) < R + cella) {
            rx = cella * 0.5 * riempimento * (0.8 + 0.4 * rv[k + 2]);
            ry = cella * 0.5 * riempimento * (0.8 + 0.4 * rv[k + 3]);
            sz = D * 1.4;
            ztop = H - D * 0.25 * rv[k + 4];
            translate([cx, cy, ztop - sz])
                rotate(rv[k + 5] * 180)
                    scale([rx, ry, sz]) sphere(1, $fn = 18);
        }
    }
}

// Sterrato / ghiaia: sassolini sparsi di altezza e dimensione casuali
module sterrato() {
    n = round(PI * R * R * densita);
    rv = rands(0, 1, n * 5, seed);
    for (i = [0 : n - 1]) {
        k = i * 5;
        a = rv[k] * 360;
        d = R * sqrt(rv[k + 1]);
        r = sasso_min + (sasso_max - sasso_min) * pow(rv[k + 2], 2);
        ztop = H - D * 0.9 * rv[k + 3];
        sz = min(r, D) * 0.9;
        translate([d * cos(a), d * sin(a), ztop - sz])
            rotate(rv[k + 4] * 180)
                scale([r, r * (0.6 + 0.4 * rv[k + 4]), sz]) sphere(1, $fn = 10);
    }
}

// Assi di legno: fessure, giunti di testa sfalsati, dislivelli e venature
module solchi_assi() {
    nr = ceil(2 * R / (assi_w * (1 - irregolarita_assi) + fessura)) + 3;
    rw = rands(-1, 1, nr, seed + 2000);
    ws = [for (j = [0 : nr - 1]) assi_w * (1 + irregolarita_assi * rw[j])];
    ys = concat([0], cumsum([for (j = [0 : nr - 1]) ws[j] + fessura]));
    nk = ceil(2 * R / (assi_l * (1 - irregolarita_assi))) + 3;
    per = 1 + 3 * venature;
    for (j = [0 : nr - 1]) {
        y0 = -R - assi_w * 0.3 + ys[j];
        w = ws[j];
        rl = rands(-1, 1, nk, seed + 3000 + j);
        ls = [for (k = [0 : nk - 1]) assi_l * (1 + irregolarita_assi * rl[k]) + fessura];
        xs = cumsum(ls);
        x0 = -R - assi_l * rands(0, 1, 1, seed + 4000 + j)[0];
        rg = rands(0, 1, nk * per, seed + 5000 + j);
        // fessura lungo il bordo superiore dell'asse
        translate([-R - 1, y0 + w, H - D]) cube([2 * R + 2, fessura, D + 1]);
        for (k = [0 : nk - 1]) {
            xa = x0 + (k == 0 ? 0 : xs[k - 1]);
            xb = x0 + xs[k] - fessura;
            b = k * per;
            dl = dislivello_assi * rg[b];
            // giunto di testa
            translate([xb, y0, H - D]) cube([fessura, w, D + 1]);
            // asse leggermente abbassata
            if (dl > 0.01)
                translate([xa, y0, H - dl]) cube([xb - xa, w, dl + 1]);
            // venature
            if (venature > 0)
                for (g = [0 : venature - 1]) {
                    gy = y0 + w * (0.2 + 0.6 * rg[b + 1 + 3 * g]);
                    gl = (xb - xa) * (0.3 + 0.5 * rg[b + 2 + 3 * g]);
                    gx = xa + ((xb - xa) - gl) * rg[b + 3 + 3 * g];
                    translate([gx, gy - vena_larghezza / 2, H - dl - vena_profondita])
                        cube([gl, vena_larghezza, vena_profondita + 1]);
                }
        }
    }
}

// Lastre di pietra: celle di Voronoi con fuga, angoli arrotondati e bordo smussato
lx = ceil(2 * R / lastre_dim) + 4;
ly = ceil(2 * R / (0.87 * lastre_dim)) + 4;
rlast = rands(0, 1, lx * ly * 3, seed + 6000);

function lpunto(i, j) =
    let (k = (i * ly + j) * 3,
         sf = (j % 2 == 0) ? 0 : lastre_dim / 2)
    [ (i - (lx - 1) / 2) * lastre_dim + sf + (rlast[k] - 0.5) * lastre_dim * lastre_disordine,
      (j - (ly - 1) / 2) * lastre_dim * 0.87 + (rlast[k + 1] - 0.5) * lastre_dim * lastre_disordine ];

// Cella di Voronoi del punto (i,j): intersezione dei semipiani verso i vicini
module cella_2d(i, j) {
    p = lpunto(i, j);
    big = 3 * lastre_dim;
    intersection_for (a = [max(i - 2, 0) : min(i + 2, lx - 1)],
                      b = [max(j - 2, 0) : min(j + 2, ly - 1)]) {
        if (a == i && b == j) {
            square(1000, center = true);
        } else {
            q = lpunto(a, b);
            m = (p + q) / 2;
            u = (q - p) / norm(q - p);
            translate(m - u * fuga / 2)
                rotate(atan2(u[1], u[0]))
                    translate([-big, -big]) square([big, 2 * big]);
        }
    }
}

module forma_lastra(i, j) {
    offset(r = lastre_raggio) offset(delta = -lastre_raggio) cella_2d(i, j);
}

module lastre() {
    rz = rands(0, 1, lx * ly, seed + 7000);
    for (i = [0 : lx - 1], j = [0 : ly - 1]) {
        if (norm(lpunto(i, j)) < R + lastre_dim) {
            ztop = H - lastre_dislivello * rz[i * ly + j];
            zb = H - D - 0.1;
            hb = ztop - lastre_smusso - zb;
            translate([0, 0, zb]) {
                linear_extrude(height = hb + 0.01) forma_lastra(i, j);
                translate([0, 0, hb])
                    linear_extrude(height = lastre_smusso)
                        offset(delta = -lastre_smusso) forma_lastra(i, j);
            }
        }
    }
}

module zona_texture() {
    translate([0, 0, -1]) cylinder(r = Rin, h = H + 2, $fn = 128);
}

module base() {
    difference() {
        union() {
            if (superficie == "liscia") {
                corpo();
            } else if (superficie == "mattoni" || superficie == "assi") {
                difference() {
                    corpo();
                    intersection() {
                        rotate(angolo_texture) {
                            if (superficie == "mattoni") solchi_mattoni();
                            else solchi_assi();
                        }
                        zona_texture();
                    }
                }
            } else {
                intersection() {
                    corpo();
                    union() {
                        // piano di fondo della texture
                        cylinder(r = R + 1, h = H - D, $fn = 128);
                        // anello esterno liscio a quota piena
                        if (bordo_liscio > 0)
                            difference() {
                                cylinder(r = R + 1, h = H, $fn = 128);
                                zona_texture();
                            }
                        intersection() {
                            zona_texture();
                            rotate(angolo_texture) {
                                if (superficie == "ciottoli") ciottoli();
                                else if (superficie == "lastre") lastre();
                                else sterrato();
                            }
                        }
                    }
                }
            }
        }
        if (diametro_magnete > 0)
            translate([0, 0, -0.01])
                cylinder(d = diametro_magnete, h = altezza_magnete + 0.01, $fn = 64);
    }
}

base();
