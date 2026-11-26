// =====================================================================
//  RIVETTI A DUE PARTI PARAMETRICI - due tipologie
// =====================================================================
//  1) tipo "scatto" - bottoni a pressione
//     (rif. img/rivetti-in-plastica-bottoni-a-pressione-3-mm-bianco.jpg)
//     maschio: testa + gambo cavo con linguotti, campanatura e denti
//     a zigrinatura; femmina: testa con colletto forato.
//
//  2) tipo "vite" - rivetti a vite A SCATTO (ratchet)
//     (rif. img/rivetti2.webp, foro M3, pannelli 0-9 mm)
//     maschio: flangia + perno dentato; femmina: flangia + mozzo bombato
//     FENDUTO in petali elastici. Non si avvitano: il perno si SPINGE nel
//     mozzo e i petali scattano di dente in dente, bloccando il serraggio
//     a qualsiasi spessore da 0 a spessore_pannello (la lunghezza del
//     perno e' calcolata di conseguenza). Per smontare bisogna forzare
//     contro la faccia ripida dei denti.
//
//  Stampa 3D: entrambe le parti si stampano senza supporti con la
//  flangia appoggiata al piatto (vista "stampa"). Per la filettatura
//  consogliato PETG/ABS; con PLA va bene per prototipi.
// =====================================================================

/* [Tipo e viste] */

// tipologia di rivetto
tipo = "vite"; // [scatto: a pressione, vite: filettato]

// parte del rivetto da visualizzare o esportare in STL
parte = "assemblato"; // [maschio, femmina, assemblato, sezione, stampa, piastra]

// mostra il pannello trasparente nelle viste "assemblato" e "sezione"
mostra_pannello = true;

// risoluzione degli archi (numero di faccette)
qualita = 96; // [24:8:200]

/* [Misure principali] */

// diametro della flangia (nel disegno 1: 11,5)
diametro_testa = 11.5; // [4:0.1:40]

// spessore della flangia
spessore_testa = 1.3; // [0.6:0.1:6]

// a scatto: diametro del foro nel pannello - a vite: diametro nominale del filetto (3 = M3)
d_nominale = 3; // [1:0.1:16]

// spessore del materiale tra le due flange (a scatto = grip; a vite = max aggrippabile)
spessore_pannello = 3; // [0:0.1:30]

/* [Parte femmina] */

// diametro del colletto / mozzo
d_colletto = 5.5; // [2:0.1:24]

// lunghezza del colletto (tipo scatto)
h_colletto = 1.2; // [0.4:0.1:10]

// lunghezza del mozzo filettato (tipo vite)
h_mozzo_vite = 3.2; // [0.8:0.1:15]

// fessure del mozzo: 1 = due petali, 2 = quattro petali (tipo vite)
tagli_mozzo = 2; // [1:2]

/* [Gambo maschio - tipo scatto] */

// gioco diametrale del gambo nel foro
gioco_gambo = 0.2; // [0:0.05:1]

// sporgenza della punta oltre la testa femmina (0 = punta a filo)
sporgenza_punta = 0; // [0:0.1:2]

// altezza della campanatura dei linguotti
h_campana = 1; // [0.4:0.1:3]

// espansione della campanatura per lato
espansione = 0.5; // [0.2:0.05:1.5]

// smusso di guida sulla punta
smusso_punta = 0.4; // [0:0.1:1]

// numero di tagli del gambo: 1 = due linguotti, 2 = quattro linguotti
n_tagli = 1; // [1:2]

// larghezza dei tagli
larghezza_taglio = 0.6; // [0.2:0.05:1.5]

// profondita' dei tagli sotto la campanatura
h_taglio_extra = 1.2; // [0.4:0.1:4]

// foro passante interno del gambo (0 = gambo pieno)
d_foro_gambo = 1.2; // [0:0.1:3]

// gioco del gambo nel foro della parte femmina
gioco_femmina = 0.15; // [0:0.05:1]

/* [Denti a pressione (entrambi i tipi)] */

// denti sul perno/gambo: aggancio a pressione "a crichetto"
zigrinatura = true;

// sporgenza dei denti per lato - tipo scatto (0.1 = scorrimento, 0.3 = molto forzato)
d_sporgenza_denti = 0.25; // [0.05:0.05:0.6]

// passo tra i denti
d_passo_denti = 0.9; // [0.5:0.1:3]

// ripidezza della faccia di ritenuta, frazione del passo
d_ripido_denti = 0.25; // [0.1:0.05:0.5]

/* [Piastra di stampa (piu' rivetti)] */

// colonne di rivetti completi (maschio + femmina) nella piastra
piastra_colonne = 3; // [1:1:10]

// righe di rivetti completi nella piastra
piastra_righe = 2; // [1:1:10]

// distanza tra un rivetto e l'altro (corridoio della griglia di supporto)
distanza_rivetti = 4; // [2:0.5:15]

// spessore della griglia di supporto (1-2 strati: si stacca piegandola)
spessore_supporto = 0.4; // [0.2:0.05:1.2]

// larghezza dei punti di collegamento (piccoli = facili da staccare)
larghezza_collegamento = 1.2; // [0.6:0.1:3]

/* [Valori calcolati] */

// ---- tipo scatto ----
d_gambo = d_nominale - gioco_gambo;      // diametro reale del gambo
h_gambo = spessore_pannello + h_colletto + spessore_testa + sporgenza_punta; // lunghezza del gambo
r_campana = d_gambo / 2 + espansione;            // raggio della campanatura
d_foro_femmina = d_gambo + gioco_femmina;        // foro della parte femmina
raggio_giro = min(spessore_testa * 0.45, 1.2);   // arrotondamento del bordo flangia
smusso_ingresso = min(0.5, h_colletto * 0.4);    // smusso d'ingresso del foro femmina
z_taglio = max(h_gambo - h_campana - h_taglio_extra, spessore_testa + 0.1); // base dei tagli
h_zona_denti = min(spessore_pannello, h_gambo - h_campana - 0.1);  // altezza zona dentata

// ---- tipo vite ----
h_punta_vite = 0.8;                  // punta rastremata non dentata
d_gambo_vite = d_nominale - 0.5;     // anima del perno (scorre nel foro del pannello)
d_cresta_vite = d_nominale - 0.05;   // cresta dei denti (passa nel foro del pannello)
d_foro_mozzo = d_cresta_vite - 0.4;  // foro del mozzo: i petali si aprono e scattano sui denti
h_filetto_vite = spessore_pannello + h_mozzo_vite + spessore_testa + sporgenza_punta; // lunghezza del perno
h_zona_vite = h_filetto_vite - h_punta_vite - 0.1; // denti su tutto il perno

$fn = qualita;

// ----------------------------- controlli ----------------------------

assert(d_colletto < diametro_testa, "il colletto / mozzo deve essere più piccolo della flangia");

if (tipo == "scatto") {
    assert(d_gambo > 0.5, "foro troppo piccolo rispetto al gioco");
    assert(smusso_punta < h_campana, "lo smusso della punta deve essere più piccolo della campanatura");
    assert(r_campana * 2 > d_foro_femmina, "la campanatura deve superare il foro femmina per potersi agganciare");
    assert(d_foro_femmina < d_colletto, "il foro femmina è più grande del colletto");
    assert(d_foro_gambo < d_gambo - 0.6, "il foro interno del gambo lascia pareti troppo sottili");
    assert(z_taglio < h_gambo - smusso_punta, "i tagli non arrivano alla campanatura: allunga h_taglio_extra");
    assert(!zigrinatura || h_zona_denti >= 0.3, "gambo troppo corto per la zigrinatura");
}

if (tipo == "vite") {
    assert(d_foro_mozzo > 1, "diametro troppo piccolo per i denti del mozzo");
    assert(h_mozzo_vite >= 2 * d_passo_denti, "mozzo troppo corto: servono almeno 2 denti in presa");
}

// ------------------------------ geometrie ---------------------------

// flangia discoidale con bordo arrotondato (comune alle due tipologie)
module testa() {
    rotate_extrude()
        hull() {
            translate([diametro_testa / 2 - raggio_giro, raggio_giro])
                circle(r = raggio_giro);
            translate([diametro_testa / 2 - raggio_giro, spessore_testa - raggio_giro])
                circle(r = raggio_giro);
            square([0.01, spessore_testa]);
        }
}

// pannello fantasma per visualizzare il serraggio
module pannello() {
    color("SteelBlue", 0.35)
        difference() {
            cylinder(d = diametro_testa * 1.1, h = spessore_pannello);
            translate([0, 0, -1])
                cylinder(d = d_nominale, h = spessore_pannello + 2);
        }
}

// --------------------- tipo "scatto": maschio -----------------------

// denti a pressione "a crichetto" da d_base a d_cresta per un'altezza h_zona:
// la rampa dolce guarda la punta (si sale spingendo),
// quella ripida guarda la flangia (blocca lo sfilamento)
module denti_pressione(d_base, d_cresta, h_zona) {
    sporg = (d_cresta - d_base) / 2;
    h_caduta = d_passo_denti * d_ripido_denti;   // faccia ripida di ritenuta
    h_rampa  = d_passo_denti - h_caduta;         // rampa di inserimento
    n_denti  = max(floor(h_zona / d_passo_denti), 1);
    for (i = [0 : n_denti - 1])
        translate([0, 0, i * d_passo_denti]) {
            cylinder(d1 = d_base, d2 = d_base + 2 * sporg, h = h_caduta);
            translate([0, 0, h_caduta])
                cylinder(d1 = d_base + 2 * sporg, d2 = d_base, h = h_rampa);
        }
}

// parte maschio: testa + gambo cavo tagliato con punta campanata
// (origine: faccia esterna della testa, gambo verso l'alto)
module maschio_scatto() {
    difference() {
        union() {
            testa();

            // profilo di revoluzione del gambo con campanatura e punta smussata
            rotate_extrude()
                polygon([
                    [0, 0],
                    [d_gambo / 2, 0],
                    [d_gambo / 2, h_gambo - h_campana],
                    [r_campana, h_gambo - smusso_punta],
                    [r_campana - smusso_punta, h_gambo],
                    [0, h_gambo],
                ]);

            // denti a zigrinatura per il fissaggio a pressione
            if (zigrinatura)
                denti_pressione(d_gambo, d_gambo + 2 * d_sporgenza_denti, h_zona_denti);
        }

        // tagli dei linguotti
        for (i = [0 : n_tagli - 1])
            rotate([0, 0, i * 180 / n_tagli])
                translate([-larghezza_taglio / 2, -(r_campana + 1), z_taglio])
                    cube([larghezza_taglio,
                          2 * (r_campana + 1),
                          h_gambo + 1 - z_taglio]);

        // foro passante del gambo (attraversa anche la testa)
        if (d_foro_gambo > 0)
            translate([0, 0, -0.5])
                cylinder(d = d_foro_gambo, h = h_gambo + spessore_testa + 1);
    }
}

// --------------------- tipo "scatto": femmina -----------------------

// parte femmina: testa + colletto con foro passante
// (origine: faccia esterna della testa, colletto verso l'alto)
module femmina_scatto() {
    difference() {
        union() {
            testa();
            translate([0, 0, spessore_testa])
                cylinder(d = d_colletto, h = h_colletto);
        }
        // foro passante
        translate([0, 0, -0.5])
            cylinder(d = d_foro_femmina, h = spessore_testa + h_colletto + 1);
        // smusso d'ingresso sul lato libero del colletto
        translate([0, 0, spessore_testa + h_colletto - 0.01])
            cylinder(d1 = d_foro_femmina,
                     d2 = d_foro_femmina + 2 * smusso_ingresso,
                     h = smusso_ingresso + 0.01);
    }
}

// --------------------- tipo "vite": maschio -------------------------

// perno dentato (ratchet) con punta rastremata d'avviamento
// (origine: faccia esterna della flangia, perno verso l'alto)
module maschio_vite() {
    h = h_filetto_vite;
    testa();
    translate([0, 0, spessore_testa]) {
        // anima del perno
        cylinder(d = d_gambo_vite, h = h - h_punta_vite);
        // punta conica d'avviamento
        translate([0, 0, h - h_punta_vite])
            cylinder(d1 = d_gambo_vite, d2 = d_gambo_vite - 1.2, h = h_punta_vite);
        // denti a scatto sull'intero perno: si bloccano a qualsiasi
        // spessore di pannello da 0 a spessore_pannello
        if (zigrinatura)
            denti_pressione(d_gambo_vite, d_cresta_vite, h_zona_vite);
    }
}

// --------------------- tipo "vite": femmina -------------------------

// dado con flangia e mozzo bombato FENDUTO in petali elastici:
// spingendo il perno i petali si aprono e scattano di dente in dente
// (origine: faccia esterna della flangia, mozzo verso l'alto)
module femmina_vite() {
    h_tot = spessore_testa + h_mozzo_vite;
    rr = min(1.2, h_mozzo_vite * 0.35);   // restringimento del mozzo in alto
    w_fessura = max(larghezza_taglio, 0.8);
    difference() {
        union() {
            testa();
            // mozzo rastremato (profilo bombato come in foto)
            translate([0, 0, spessore_testa])
                cylinder(d1 = d_colletto, d2 = d_colletto - 2 * rr, h = h_mozzo_vite);
        }
        // foro del mozzo (sotto la cresta dei denti: i petali li bloccano)
        translate([0, 0, -0.5])
            cylinder(d = d_foro_mozzo, h = h_tot + 1);
        // smusso d'ingresso sul lato libero del mozzo
        translate([0, 0, h_tot - 0.6])
            cylinder(d1 = d_foro_mozzo, d2 = d_foro_mozzo + 1.2, h = 0.61);
        // fessure dei petali (lungo tutto il mozzo, fino alla flangia)
        for (i = [0 : tagli_mozzo - 1])
            rotate([0, 0, i * 180 / tagli_mozzo])
                translate([-w_fessura / 2, -d_colletto, spessore_testa])
                    cube([w_fessura, 2 * d_colletto, h_mozzo_vite + 0.5]);
    }
}

// ------------------------------ comuni ------------------------------

module maschio() {
    if (tipo == "vite") maschio_vite();
    else maschio_scatto();
}

module femmina() {
    if (tipo == "vite") femmina_vite();
    else femmina_scatto();
}

// parte femmina in posizione di montaggio (flangia in alto, mozzo in basso)
module femmina_montata() {
    hc = (tipo == "vite") ? h_mozzo_vite : h_colletto;
    translate([0, 0, 2 * spessore_testa + spessore_pannello + hc])
        rotate([180, 0, 0])
            femmina();
}

// rivetto montato con il pannello in mezzo
module vista_assemblato() {
    color("White") maschio();
    color("Gainsboro") femmina_montata();
    if (mostra_pannello)
        translate([0, 0, spessore_testa]) pannello();
}

// rivetto montato tagliato a meta' per vedere l'aggancio interno
module vista_sezione() {
    difference() {
        union() {
            color("White") maschio();
            color("Gainsboro") femmina_montata();
            if (mostra_pannello)
                translate([0, 0, spessore_testa]) pannello();
        }
        translate([-diametro_testa, -diametro_testa * 1.2, -1])
            cube([diametro_testa * 2, diametro_testa * 1.2, diametro_testa * 3]);
    }
}

// entrambe le parti in posizione di stampa (flangia sul piatto)
module stampa() {
    maschio();
    translate([diametro_testa + d_colletto / 2 + 3, 0, 0])
        femmina();
}

// ------------------- piastra di stampa (array) ----------------------

// punto di collegamento elastico tra una flangia e la traversa piu' vicina:
// sottile per staccarlo facilmente, entra 1 mm nella flangia per
// aderire bene anche alla base arrotondata
module collegamento(px, py, r, x0, x1, y0, y1) {
    sovrapp = min(1, r * 0.5);   // penetrazione nel bordo flangia
    // traversa a sinistra
    translate([x0 + 2 * larghezza_collegamento - 0.5, py - larghezza_collegamento / 2, 0])
        cube([px - r + sovrapp - (x0 + 2 * larghezza_collegamento - 0.5),
              larghezza_collegamento, spessore_supporto]);
    // traversa a destra
    translate([px + r - sovrapp, py - larghezza_collegamento / 2, 0])
        cube([(x1 - 2 * larghezza_collegamento + 0.5) - (px + r - sovrapp),
              larghezza_collegamento, spessore_supporto]);
    // traversa in basso
    translate([px - larghezza_collegamento / 2, y0 + 2 * larghezza_collegamento - 0.5, 0])
        cube([larghezza_collegamento,
              py - r + sovrapp - (y0 + 2 * larghezza_collegamento - 0.5),
              spessore_supporto]);
    // traversa in alto
    translate([px - larghezza_collegamento / 2, py + r - sovrapp, 0])
        cube([larghezza_collegamento,
              (y1 - 2 * larghezza_collegamento + 0.5) - (py + r - sovrapp),
              spessore_supporto]);
}

// piastra di stampa: array di rivetti completi (maschio + femmina per
// cella) uniti da una griglia sottile di supporto. La griglia ha una
// grande superficie di adesione sul piatto e si stacca piegandola: i
// punti di collegamento si rompono al bordo delle flange.
module piastra_stampa() {
    offset_coppia = diametro_testa + d_colletto / 2 + 3;      // distanza centri m/f
    larghezza_cella = offset_coppia + diametro_testa;         // contenuto della cella
    px_pitch = larghezza_cella + distanza_rivetti;
    py_pitch = diametro_testa + distanza_rivetti;
    bw = 2 * larghezza_collegamento;                          // larghezza traversaie
    lx = piastra_colonne * px_pitch;
    ly = piastra_righe * py_pitch;
    R = diametro_testa / 2;
    union() {
        // traversaie verticali sui confini delle colonne
        for (k = [0 : piastra_colonne])
            translate([k * px_pitch - bw / 2, -bw / 2, 0])
                cube([bw, ly + bw, spessore_supporto]);
        // traversaie orizzontali sui confini delle righe
        for (k = [0 : piastra_righe])
            translate([-bw / 2, k * py_pitch - bw / 2, 0])
                cube([lx + bw, bw, spessore_supporto]);
        // rivetti e punti di collegamento
        for (cy = [0 : piastra_righe - 1], cx = [0 : piastra_colonne - 1]) {
            x0 = cx * px_pitch;
            y0 = cy * py_pitch;
            mx = x0 + distanza_rivetti / 2 + R;
            my = y0 + distanza_rivetti / 2 + R;
            fx = mx + offset_coppia;
            translate([mx, my, 0]) maschio();
            translate([fx, my, 0]) femmina();
            collegamento(mx, my, R, x0, x0 + px_pitch, y0, y0 + py_pitch);
            collegamento(fx, my, R, x0, x0 + px_pitch, y0, y0 + py_pitch);
        }
    }
}

// ------------------------------ output ------------------------------

if (parte == "maschio")            maschio();
else if (parte == "femmina")       femmina();
else if (parte == "assemblato")    vista_assemblato();
else if (parte == "sezione")       vista_sezione();
else if (parte == "stampa")        stampa();
else if (parte == "piastra")       piastra_stampa();

// ------------------------------- note -------------------------------
// Il tipo "vite" riprende img/rivetti2.webp: foro M3, pannelli 0-9 mm.
// NON si avvita: il perno dentato si spinge nel mozzo fenduto e i petali
// scattano di dente in dente (ratchet) serrando il pannello a qualsiasi
// spessore da 0 a spessore_pannello. Cambia spessore_pannello e la
// lunghezza del perno si adatta da sola.
//
// Esempi di varianti:
//   perno piu' mordente     ->  d_passo_denti = 0.7; d_ripido_denti = 0.3;
//   mozzo piu' elastico     ->  tagli_mozzo = 2 (quattro petali);
//   flangia piu' piccola    ->  diametro_testa = 9.5;
//   rivetto a scatto semplice ->  tipo = "scatto";
//   gambo pieno (scatto)    ->  d_foro_gambo = 0;
//   quattro linguotti (scatto) ->  n_tagli = 2;
//   zigrinatura morbida (scatto) ->  d_sporgenza_denti = 0.15;
//   piastra 3x2 di rivetti      ->  parte = "piastra"; (colonne/righe nei parametri)
