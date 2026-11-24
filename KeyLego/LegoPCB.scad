/*
 *  LegoPCB.scad
 *  ------------------------------------------------------------------
 *  Mattoncino LEGO portamicrocontrollore.
 *
 *  Un mattoncino LEGO (attacco femmina sotto, tasselli sopra) al cui
 *  interno si inserisce e blocca una PCB (Arduino, Raspberry Pi Pico,
 *  ESP32, ...), con apertura per la porta USB (USB-C o Micro-USB).
 *
 *  Architettura (come in LegoPlate.scad):
 *   - ANELLO di bordo: mattoncini LEGO a fondo aperto (femmina sotto,
 *     tasselli sopra);
 *   - POZZETTO centrale: blocco pieno con vano per la PCB ricavato
 *     dall'alto (stampabile senza supporti);
 *   - la PCB si inserisce dall'alto nel vano e viene bloccata dai
 *     labbri perimetrali (rim, sporgenti verso l'interno, con la faccia
 *     superiore della PCB a filo del labbro);
 *   - finestra della porta USB attraverso parete e anello sul lato corto
 *     della PCB (i pin dell'attacco femmina nella zona della finestra
 *     vengono omessi via stud_matrix);
 *   - la connettore USB sporge oltre il bordo PCB: il vano e' allungato
 *     sul lato porta e il bordo del pozzetto e' aperto fino in cima
 *     (tacca) per lasciar passare connettore e cavo.
 *
 *  Coordinate: il mattoncino occupa [0..L] x [0..W], z=0 sotto.
 *  La PCB e' centrata in Y; la porta USB e' sul lato corto (x+ o x-).
 *  ------------------------------------------------------------------
 */

use <LEGO.scad>

/* [PCB] */
// Formato PCB
pcb = "pico"; // [pico:Pico 51.4x21, nano:Nano 45x18, esp32:ESP32 48.3x25.4, custom:Personalizzata]
// Larghezza PCB personalizzata, lungo X (mm)
pcb_l_c = 51.4;
// Profondita' PCB personalizzata, lungo Y (mm)
pcb_w_c = 21.0;
// Spessore PCB personalizzato (mm)
pcb_t_c = 1.6;

/* [Porta USB] */
// Tipo di porta sul lato corto della PCB
port = "usbc"; // [usbc:USB-C, microusb:Micro-USB, none:Nessuna, custom:Personalizzata]
// Lato della porta
port_side = "front"; // [front:x+, back:x-]
// Larghezza porta personalizzata (mm)
port_w_c = 8.94;
// Altezza porta personalizzata (mm)
port_h_c = 3.26;
// Sporgenza del connettore oltre il bordo PCB (mm)
port_overhang = 1.5;
// Centro del connettore sopra il piano inferiore della PCB (mm)
port_center = 0.8;

/* [Alloggiamento] */
// Gioco laterale attorno alla PCB (mm)
fit_clear = 0.3;
// Spazio sotto la PCB (saldature/componenti) (mm)
under_clear = 1.2;
// Quanto la PCB resta sotto il piano superiore = altezza labbro (mm)
top_clear = 0.8;
// Sporgenza del labbro di blocco sul bordo del vano (mm, 0 = nessun labbro)
lip = 0.35;
// Cornice di plastica attorno al vano, sul piano superiore (mm)
well_frame = 3.0;

/* [Mattoncino LEGO] */
// Anello di tasselli attorno al vano (in passi da 8 mm)
margin_studs = 1; // [0:1:3]
// Spessore del mattoncino in mm (min 4.8)
plate_th = 6.4; // [4.8:1.6:11.2]
// Riscala solo i tasselli per compensare la stampante (1.05 = +5%)
stud_rescale = 1.00; // [0.90:0.005:1.20]

/* [Anteprima] */
// Mostra la PCB fantasma (solo F5)
show_pcb = true;

/* [Nascosto] */
stud_pitch = 8;       // passo dei tasselli LEGO
wall_play  = 0.1;     // gioco fra mattoncini adiacenti (come in LEGO.scad)
stud_h     = 1.8;     // altezza tassello
brick_unit_th  = 9.6; // altezza di 1 mattoncino LEGO
pin_clear  = 2.0;     // margine pin-omissione attorno alla finestra USB

// ------------------------------------------------------------------
// Dimensioni PCB
// ------------------------------------------------------------------

pcb_l = pcb == "pico"  ? 51.4
      : pcb == "nano"  ? 45.0
      : pcb == "esp32" ? 48.3
      : pcb_l_c;
pcb_w = pcb == "pico"  ? 21.0
      : pcb == "nano"  ? 18.0
      : pcb == "esp32" ? 25.4
      : pcb_w_c;
pcb_t = pcb == "pico"  ? 1.6
      : pcb == "nano"  ? 1.6
      : pcb == "esp32" ? 1.6
      : pcb_t_c;

assert(pcb_l >= pcb_w, "La PCB deve avere il lato lungo lungo X (pcb_l >= pcb_w)");
assert(plate_th >= pcb_t + under_clear + top_clear + 1.2,
       "plate_th troppo sottile per il vano: aumenta plate_th o riduci under_clear/top_clear");

// ------------------------------------------------------------------
// Porta USB
// ------------------------------------------------------------------

port_w = port == "usbc"     ? 8.94
       : port == "microusb" ? 7.6
       : port_w_c;
port_h = port == "usbc"     ? 3.26
       : port == "microusb" ? 2.6
       : port_h_c;
has_port = port != "none";

// ------------------------------------------------------------------
// Misure derivate
// ------------------------------------------------------------------

front = port_side == "front";
port_extra = has_port ? port_overhang + 1.0 : 0.4;

// vano (pocket) per la PCB
pocket_l = pcb_l + 2 * fit_clear + port_extra;
pocket_w = pcb_w + 2 * fit_clear;
// profondita' vano = spessore pcb + spazio sotto + labbro (min fondina 1.2)
pocket_d = min(pcb_t + under_clear + top_clear, plate_th - 1.2);

// pozzetto (campo pieno) e mattoncino
field_l_min = pocket_l + 2 * well_frame;
field_w_min = pocket_w + 2 * well_frame;
studs = [ ceil((field_l_min + 2 * margin_studs * stud_pitch) / stud_pitch),
          ceil((field_w_min + 2 * margin_studs * stud_pitch) / stud_pitch) ];
plate = [ studs[0] * stud_pitch - 2 * wall_play,
          studs[1] * stud_pitch - 2 * wall_play ];

// il pozzetto riempie l'interno dell'anello (0.2 di gioco dalle pareti):
// la cornice reale attorno al vano e' >= well_frame grazie all'arrotondamento
field_l = plate[0] - 2 * margin_studs * stud_pitch;
field_w = plate[1] - 2 * margin_studs * stud_pitch;
field_x0 = margin_studs * stud_pitch;
field_y0 = margin_studs * stud_pitch;
pocket_x0 = field_x0 + (field_l - pocket_l) / 2;
pocket_y0 = field_y0 + (field_w - pocket_w) / 2;
pocket_x1 = pocket_x0 + pocket_l;
pocket_y1 = pocket_y0 + pocket_w;

// la PCB appoggia con il bordo superiore sul labbro (o sul fondo vano)
z1 = plate_th - top_clear;          // piano del bordo superiore PCB = base del labbro

seat_z = plate_th - pocket_d;      // fondo del vano
pcb_x0 = pocket_x0 + fit_clear;
pcb_y0 = pocket_y0 + fit_clear;
pcb_cy = plate[1] / 2;

// finestra porta USB
conn_face_x = front ? pcb_x0 + pcb_l + port_overhang
                    : pcb_x0 - port_overhang;
win_cy = pcb_cy;
win_w = port_w + 1.4;
win_h = port_h + 1.4;
win_cz = seat_z + under_clear + port_center;
win_z1 = min(win_cz + win_h / 2, plate_th - top_clear - 0.05); // non tocca il labbro
win_z0 = max(win_cz - win_h / 2, seat_z + 0.2);

// ------------------------------------------------------------------
// Moduli
// ------------------------------------------------------------------

// Posiziona un mattoncino LEGO.scad con l'angolo su (cx, cy), base a z.
// LEGO.scad disegna sempre il lato lungo lungo X: con rot=90 corre lungo Y.
module brick_at(width, length, cx, cy, z, rot = 0, height = 1,
                stud_matrix = "", matrix_columns = 0) {
    oL = max(width, length) * stud_pitch - 2 * wall_play;
    oW = min(width, length) * stud_pitch - 2 * wall_play;
    translate(rot == 0 ? [ cx + oL / 2, cy + oW / 2, z ]
                       : [ cx + oW / 2, cy + oL / 2, z ])
        rotate([0, 0, rot])
            block(width = width, length = length, height = height,
                  stud_rescale = stud_rescale,
                  stud_matrix_string = stud_matrix,
                  stud_matrix_columns = matrix_columns);
}

// Anello di bordo: mattoncini a fondo aperto (femmina sotto, tasselli sopra).
// Sul lato porta i pin che finirebbero nella finestra USB vengono omessi.
module lego_ring(h) {
    m = margin_studs;
    n = studs[1] - 2 * m;
    side_mtx = has_port ? port_pin_matrix(n) : "";
    if (m > 0) {
        brick_at(m, studs[0], 0, 0, 0, height = h);                          // frontale (y0)
        brick_at(m, studs[0], 0, stud_pitch * (studs[1] - m), 0, height = h);// posteriore (y1)
        brick_at(1, n, 0, stud_pitch * m, 0, rot = 90, height = h,         // sinistro (x0)
                 stud_matrix = !front ? side_mtx : "",
                 matrix_columns = n);
        brick_at(1, n, stud_pitch * (studs[0] - 1), stud_pitch * m, 0,
                 rot = 90, height = h,                                     // destro (x1)
                 stud_matrix = front ? side_mtx : "",
                 matrix_columns = n);
    }
}

// matrice "tutto punto" per i pin nel raggio della finestra USB
// (i pin del mattoncino laterale sono a y = m*8 + 3.9 + 8*i)
function port_pin_matrix(n) =
    chr([ for (i = [0 : n - 1])
          abs((stud_pitch * margin_studs + 3.9 + 8 * i) - win_cy) < win_w / 2 + pin_clear ? 46 : 42 ]);

// Pozzetto centrale: blocco pieno (stampabile senza supporti)
module pcb_well() {
    translate([ field_x0, field_y0, 0 ])
        cube([ field_l, field_w, plate_th ]);
}

// Vano PCB: vano pieno fino al piano del labbro, poi apertura rientrata
// (labbro) fino al piano superiore. Il connettore USB resta dentro il vano:
// la sua faccia e' piu' interna del bordo vano (port_extra) e la sua parte
// alta passa nell'apertura rientrata; il cavo entra dalla finestra.
module pcb_pocket() {
    z1 = plate_th - top_clear;
    // vano principale
    translate([ pocket_x0, pocket_y0, seat_z - 0.5 ])
        cube([ pocket_l, pocket_w, z1 - seat_z + 0.51 ]);
    // apertura rientrata (labbro) sul piano superiore
    translate([ pocket_x0 + lip, pocket_y0 + lip, z1 - 0.01 ])
        cube([ pocket_l - 2 * lip, pocket_w - 2 * lip, top_clear + 0.51 ]);
}

// Finestra della porta USB attraverso pozzetto e anello
module usb_window() {
    if (has_port) {
        x0 = front ? conn_face_x - 0.3 : -1;
        x1 = front ? plate[0] + 1 : conn_face_x + 0.3;
        translate([ x0, win_cy - win_w / 2, win_z0 ])
            cube([ x1 - x0, win_w, win_z1 - win_z0 ]);
    }
}

// PCB fantasma (solo F5)
module pcb_preview() {
    if ($preview && show_pcb) {
        %translate([ pcb_x0, pcb_y0, seat_z + under_clear ])
            cube([ pcb_l, pcb_w, pcb_t ]);
        if (has_port)
            %translate([ front ? pcb_x0 + pcb_l + port_overhang - 7 : pcb_x0 - port_overhang,
                         pcb_cy - port_w / 2, seat_z + under_clear + port_center - port_h / 2 ])
                cube([ 7, port_w, port_h ]);
    }
}

// ------------------------------------------------------------------
// Modello
// ------------------------------------------------------------------

echo(str("PCB: ", pcb_l, " x ", pcb_w, " x ", pcb_t, " mm (", pcb, ")"));
echo(str("Mattoncino: ", studs[0], "x", studs[1], " tasselli (",
         plate[0], " x ", plate[1], " x ", plate_th, " mm)"));
echo(str("Vano: ", pocket_l, " x ", pocket_w, " x ", pocket_d,
         " mm, fondo a z=", seat_z, ", porta ", port, " sul lato ", port_side));

difference() {
    union() {
        lego_ring(plate_th / brick_unit_th);
        pcb_well();
    }
    pcb_pocket();
    usb_window();
}

pcb_preview();
