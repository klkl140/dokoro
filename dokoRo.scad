// der DoppelKopfRoboter
// (c) Klaus Kloos 160630
//
// die 0-Achse liegt in der Mitte der horizontalen Winkelverstellung

use <pibase.scad>                                   // pi board und halter
use <OpenSCADLibs/ParametricHerringboneGears.scad>  // erzeugt die Zahnräder aufgrund von Zahnanzahl und Abstand
use <OpenSCADLibs/servo9g.scad>
use <OpenSCADLibs/CameraAdapter.scad>               // fuer die Raspberry-Kamera
use <Font/font_DesignerBlock_lo.scad>
use <ISOThreadCust.scad>
use <MCAD/bearing.scad>

// neu, noch nicht gedruckt
//
// was fehlt noch?
// -Kabelbefestigung
//
// was soll gemalt werden?
paintAll3D = 0;                         // alle Teile an ihren Positionen evtl mit Animation
paintAll2D = 0;                         // dies kann mit einem Laser gemacht werden

if(!paintAll3D){         // hier kommen die einzelnen Teile für die Fertigung
    //seitenwand();						// 2* die Seiten
    //cardholder();                     // kartenauflage, hier liegen die Karten
    //separierer(separierer);
    //scheibeHalterUnten();             // 2* neben den Kugellagern zur Führung des Gummis
    //rotate([180,0,0]) halterUnten();  // mit den unteren beiden Kugellagern
    //rotate([0,-180,0]) motorKlemme(); // hiermit wird der Motor befestigt
    //antriebsRad();  // 2* die oberen Antriebsräder
    halterOben(0);                    // ohne Antrieb
    //bothGears();                      // beide Zahnräder, fürs Drucken Auflösung einstellen!
    //rotate([45,0,0])anpressrolle();   // der mit dem Servo bewegte Greifer
    //raspbiHalter();                   // der Halter für den Raspberry
    //kameraHalter();                   // Kamera fuer den Blick auf die Karten
	//piCameraBackCover(-0.2);	        // der Schiebedeckel zur Kamera
    //motor();                          // Dummy des Motors, muss nicht gedruckt werden
}

// Animation
t_cardUp = .3;                      // die Zeit in der die Karte nach oben fährt
t_drehung = .5;                     // nach dieser Zeit ist die Drehung fertig
t_cardUp2 = .7;                     // die zweite Bewegung der Karte

cardRaw = [59, 90, 0.5];            // eine Spielkarte
card = [cardRaw.x+1,cardRaw.y+3];   // mit ein wenig Spiel

gummiB = 4+.5;                      // Breite des Gummies + Freiraum
gummiD = 1;                         // die Dicke des Gummis

swSchenkelH = 35;                   // die Breite des horizontalen Seitenwand-Schenkels, in der Mitte der Schlitz
swAddY = 5;                         // auf der Seite der Antriebsräder etwas breiter für die Schrift
swSchenkelV = swSchenkelH+swAddY;   // und damit der Servohebel geführt wird
// die Abmasse der flach liegende Seitenwand
seitenwand = [card.y+swSchenkelH/2+swAddY   // horizontal    
    , card.y+swSchenkelH/2                  // vertical
    ,3];                                    // dicke

auflageD = 3;                       // cardholder und der obere Halter
breiteStegUnten = 15;
KL625frei = bearingWidth(model=625)+1; // ein wenig Spiel
rolleObenD = 38;                    // Duchmesser der Antriebsrolle oben
rolleObenB = gummiB+.5;             // die Breite
bohrungHalter = 3.5;                // fuer beide Halter, war 3
bohrungHalterX = 12;                // jeweils der Abstand vom Rand
screwholeBottomY = 10;
screwholeTopY = 81;
achseAntrieb = 3;                   // muss auch in ParametricHerringboneGears eingestellt werden
motorHalter=[17,20];                // der Bock an dem der Motor befestigt wird [x,y]
motorHalterBohrungD=2.5;            // die Befestigung des oberen Stuecks
motorHalterBohrungZ=5;              // wie tief sollen die Loecher sein?
motorZ = 12;                        // die Dicke des Motors 
breiteStuetzeRB=14;                 // die Stützen des Raspbi-Halters
RBueberlappung=10;                  // Überlappung zwischen Raspbi-Halter und Seitenwand
RBueberlappungD=2;                  // das Material neben der Seitenplatte
armServorolleD=2;                   // die Dicke des beweglichen Arms und bestimmt damit auch die Gesamtbreite 
separiererY = 8;                    // oben haben wir 8mm um einen Kartenseparierer unterzubringen
keilH = 15;                         // für den Kartenhalter seitlich
achseMotorD=20;                     // zwischen Motor und Antriebsachse, y-Richtung
achseMotorDm=19.8;                  // die dort liegenden Zahnräder brauchen etwas Spiel
uebersetzung = [10,16];             // die beiden Antriebszahnräder, war [15/15]
                                    // [10,16] läuft gleichmaessiger, mehr Kraft
        
//berechnetes
abstandSeiten = card.x+2*armServorolleD+1;  // der Abstand der beiden Seiten auf der Innenseite
                                            // etwas Spiel für die Mechanik, innen gemessen
nebenKarten = (abstandSeiten-card.x)/2;     // der Platz neben den Karten. hier liegen die seitlichen
                                            // Haltekeile, die Führungsscheiben und der Servoarm
separierer = [abstandSeiten-2*nebenKarten,separiererY,keilH];

bM3 = 2.6;          // die Dicke der Mutter, 2.5 war zuwenig, 2.7 aber nicht fest
holeM3 = 3.5;       // da passt die Schraube durch
module tascheM3(){
    b=6;            // der Durchmesser für die 6-eckige Mutter
    cylinder(d=b, h=bM3, $fn=6);
    b1=b*.9;        // die zur Mutter gehörende Breite
    translate([-10,-b1/2,0])cube([10,b1,bM3]);
}

// eine Bohrung fuer eine gesenkte Schraube
module countersunkHole(bohrungD,dicke){
    union(){
        cylinder((dicke+.5)/2, d=bohrungD, $fn=15);
        translate([0,0,(dicke+.2)/2])
            cylinder((dicke+.5)/2, r1=bohrungD/2, r2=bohrungD, $fn=15);
    }
}

module langloch(l, breite, dicke){
    for(pos=[0,-l])translate([pos,0,0])cylinder(d=breite,h=dicke,$fn=20);
    translate([-l,-breite/2,0])cube([l,breite,dicke]);
 }

// eine verschiebbare Mutter
module slotM3(dicke, laenge){
    mutterX = 5.5;  // die Mutter soll sich verschieben lassen
    translate([-holeM3/2,0,-.1]) union(){
        //oben soll Platz für die Mutter sein
        cube([holeM3,laenge,dicke/2+.1]);
        //die andere Hälfte bleibt mit der Bohrung
        translate([-(mutterX-holeM3)/2,0,dicke/2]) cube([mutterX,laenge,dicke/2+.2]);
    }
}

module seitenwand(){
    schlitz=3;                          // die Breite der Schlitze für die Winkelverstellung
    hSchlitzLaenge=card.y-8;            // der horizontale Schlitz
    halbeSW = swSchenkelH/2;
    difference(){
        linear_extrude(height = seitenwand.z, convexity = 10)
            polygon(points=[[0,0]
                        ,[seitenwand.x,0],[seitenwand.x,swSchenkelH]
                        ,[swSchenkelV,swSchenkelH]
                        ,[swSchenkelV,seitenwand.y]
                        ,[0,seitenwand.y]]);
        translate([15,hSchlitzLaenge-3,-.1]) rotate([0,0,90])
            difference(){
                label("dokoro", size=4, height=seitenwand.z+.2);
                // mit einem Steg fixieren wir die haltlosen Innen-Stücke der 'O's
                translate([-18,1.8,0]) cube([45,1,seitenwand.z+.2]);
            }
        // der vertikale Schlitz
        translate([halbeSW+swAddY,halbeSW,-.1]) cube([schlitz,hSchlitzLaenge,seitenwand.z+.2]);
        // der horizontale Schlitz
        translate([swSchenkelV-5,halbeSW,-.1]) cube([70,schlitz,seitenwand.z+.2]);
        // die Löcher für die Befestigung des Raspi-Halters
        for(i=[breiteStuetzeRB/2,seitenwand.y-breiteStuetzeRB/2+swAddY]){
            translate([i,RBueberlappung/2,-.1])
                cylinder(d=holeM3,h=seitenwand.z+.2, $fn=20);
        }
    }
}

module cardholder(){
    // hier liegen die Karten
    // die gesamte Breite des cardholder wird durch abstandSeiten bestimmt
    // neben den eigentlichen Karten soll ein Keil dafür sorgen das die Karten richtig fallen
    // daneben gibt es noch eine Führung für das Gummi
    KLloch = [KL625frei+nebenKarten,10];    // Freiraum Kugellager in Richtung Achse/Gummies
    wds = nebenKarten;            // Wanddicke am Separierer
    difference(){
        cube([abstandSeiten, card.y+separiererY, auflageD]);    // die eigentliche Unterlage
        // die Auschnitte fuer die Rollen mit etwas Spiel
        for(x=[-.1,abstandSeiten-KLloch.x+.1]){
            translate([x,-.1,-.1]) cube([KLloch.x,KLloch.y,auflageD+.2]);
        }
        // in der Mitte braucht es kein Material
        breiteStege = 10;                       // die Seiten, nur für mechanische Festigkeit
        translate([breiteStege,breiteStegUnten,-.1])
            cube([abstandSeiten-2*breiteStege,55,auflageD+.2]);
        // und die Bohrungen fuer die Befestigung oben und unten
        posX=bohrungHalterX+nebenKarten;
        for(pos=[[posX,screwholeBottomY]
            ,[abstandSeiten-posX,screwholeBottomY]
            ,[posX,screwholeTopY]
            ,[abstandSeiten-posX,screwholeTopY]])
        {
            translate([pos.x,pos.y,-.1]) countersunkHole(bohrungD=bohrungHalter, dicke=auflageD);
        }
        translate([abstandSeiten+.1,card.y+separiererY+.1,-.1])einKeil(separiererY+5, abstandSeiten+.2, 3, 0, [90,0,270]);
        
    }
    // der untere Kartenhalter
    halterX = abstandSeiten-2*KLloch.x;
    translate([(abstandSeiten-halterX)/2,0,0]) cube([halterX,auflageD,25]);
    // die seitlichen Keile zum halten des Kartenstapels
    breiteOben = .8;    //oben nicht zu duenn, wird instabil
    for(pos=[[0,card.y,[90,0,0]]    // x, y, drehung
        ,[abstandSeiten,KLloch.y,[90,0,180]]])
    {
        translate([pos.x,pos.y,auflageD])
            einKeil(nebenKarten, card.y-KLloch.y, keilH, breiteOben, pos[2]);

    }
    difference(){
        for(pos = [[0,card.y],[abstandSeiten-wds,card.y]]){
            translate([pos.x,pos.y,auflageD])difference(){
                cube([wds,separiererY,keilH]);
                translate([-.1,separiererY/2,keilH/2])rotate([0,90,0]){
                    langloch(3,3.5,wds+.2);    
                }
            }
        }
    }
    // dann noch die Führungen des Gummis
    fuehrungX=2;    // Breite der Führung, Keil+Erhöhung
    for(pos=[[nebenKarten+gummiB,KLloch.y,[90,0,180]]
        ,[abstandSeiten-(nebenKarten+gummiB)-fuehrungX,card.y,[90,0,0]]])
    {
        translate([pos.x,pos.y,auflageD]) einKeilFuehrung(fuehrungX,card.y-KLloch.y,pos[2]);
    }
    %translate([wds,card.y,auflageD])separierer(separierer);
}

module separierer(size){
    b = gummiB+nebenKarten;
    difference(){
        cube(size);
        translate([b,-.1,-.1])cube([size.x-2*b,size.y+.2,size.z-4]);
        // die Taschen und die Löcher für die Muttern
        translate([-.1,size.y/2,size.z/2]){
            for(i=[2,size.x-2-bM3])
                translate([i,0,-.1])rotate([0,90,0]){
                    tascheM3();
                }
            // die Löcher für die Befestigung
            rotate([0,90,0])cylinder(d=holeM3,h=size.x+.2, $fn=25);
        }
    }
}

module einKeil(breite, laenge, hoehe, breiteOben, rot){
    rotate(rot)
        linear_extrude(height=laenge, convexity = 10)
            polygon(points=[[0,0], [breite,0], [breiteOben,hoehe], [0,hoehe]]
                , paths=[[0,1,2,3]]);
}

module einKeilFuehrung(breite, laenge, rot){
    breiteKeil=1;
    fuehrungZ=gummiD-.2;
    translate([breiteKeil,0,0]) union(){
        einKeil(breiteKeil, laenge, fuehrungZ, 0, rot);
        rotate([rot.x+270,rot.y,rot.z+180])cube([breite-breiteKeil,laenge,fuehrungZ]);
    }
}

module halterUnten(){
    union(){
        platteX = card.x-2*KL625frei;
        translate([KL625frei,-2.5,-auflageD]) 
            difference(){
                cube([platteX,breiteStegUnten+2.5,auflageD]);       // die Platte
                // die Langloecher fuer die Befestigung unten
                posX = bohrungHalterX-KL625frei;
                langloch=9;
                for(pos=[posX,platteX-posX]){
                    translate([pos,langloch*1.5+2,auflageD]) rotate([180,0,0])
                        slotM3(laenge=langloch,dicke=auflageD);
                }
            }
        // die Achse
        translate([-nebenKarten,0,-auflageD-bearingInnerDiameter(model=625)/2])
            difference(){
                union(){
                    rotate([0,90,0]) cylinder(d=bearingInnerDiameter(model=625)-.1,h=abstandSeiten,$fn=20);
                    // und die Verstaerkung
                    translate([KL625frei+nebenKarten,-2.5,-.4]) cube([platteX, 5, 5]);
                }
                // das durchgehende Loch fuer die Befestigung der seitlichen Schrauben
                rotate([0,90,0]) translate([0,0,-.1]) cylinder(d=3.1,h=abstandSeiten+.2,$fn=20);
            }
        
        // die Rollen als Kugellager 625
        for(pos=[0,card.x-KL625frei]){
            translate([.5+pos,0,auflageD-bearingOuterDiameter(model=625)/2-.5])
                %color("Gray") bearing(model=625,angle=[0,90,0]);
        }
    }
}

module scheibeHalterUnten(){
    aussenD=bearingOuterDiameter(model=625)+4;                      // etwas größer um das Gummi zu führen
    difference(){
        union(){
            //damit es nicht schleift gibt es innen einen Absatz
            cylinder(d=bearingInnerDiameter(model=625)+4,h=nebenKarten);
            cylinder(d=aussenD,h=nebenKarten-.5);
        }
        translate([0,0,-.1]) cylinder(d=bearingInnerDiameter(model=625)+.5, h=nebenKarten+.2);
    }
}

module seiteHalterOben(dim){  // die Führung für die oberen Antriebsräder
    difference(){
        cube(dim);
        // winklig den unnötigen Teil abschneiden
        translate([-.1,-dim.y/2,0]) rotate([-45,0,0]) cube([dim.x+.2,dim.y,23]);
    }
}

module halterOben(maleAntrieb){
    achseZ = rolleObenD/2-auflageD; // die Position der Drehachse
    achseY = 15;                    // Verschiebung in Kartenrichtung
    halterY = 15;                   // Breite des Halters auf der Kartenunterlage
    achseFutter=8;                  // Material um die Achse herum
    motorX = 23;                    // die seitliche Position des Motors
    seiteX = 4;                     // da kommt das 683 Lager hinein

    abstandSeitenX = rolleObenB+.5;  // mit etwas Spiel
    // und die beiden äusseren Blöcke und Schraubenloecher fuer die seitliche Befestigung
    breiteBlock=abstandSeitenX+nebenKarten;
    posHalterX = 15;                // Motor, das Langloch soll frei bleiben
    yBase = -(motorHalter.y-halterY);    // hier liegt die eine Seite der Motorbefestigung

    difference(){
        union(){
            cube([card.x,halterY,auflageD]);    // die Grundplatte
            // die Seiten, die Befestigung an den Seitenplatten, Antrieb, ...
            difference(){
                union(){
                    breite = achseY+halterY+achseFutter;
                    hoehe = achseZ+achseFutter+10;
                    // die Seiten
                    translate([0,achseY-breite,0]){
                        translate([abstandSeitenX,0,0])
                            difference(){
                                seiteHalterOben([seiteX,breite,hoehe]);
                                //etwas wegschneiden fuer den Motoranschluss
                                wegX=2;     //wieviel soll weggenommen werden
                                translate([seiteX-wegX+.1,22,5]){
                                    b=14;
                                    cube([wegX,b,hoehe-8]);
                                    //für das einfachere Drucken bauen wir noch eine Schräge ein
                                    translate([0,b,hoehe-8-.1])rotate([90,0,0])linear_extrude(height=b){
                                        polygon(points=[[0,0],[wegX,0],[wegX,wegX]]);
                                    }
                                }
                            }
                        translate([card.x-seiteX-abstandSeitenX,0,0])
                            seiteHalterOben([seiteX,breite,hoehe]);
                    }
                    if(maleAntrieb){
                        translate([0,-achseY,achseZ]){
                            // die Rollen, die Aussparung ist aussen
                            translate([rolleObenB,0,0])rotate([0,90,180]) antriebsRad();
                            translate([card.x-rolleObenB,0,0])rotate([0,90,0]) antriebsRad();
                            // die Achse
                            %translate([-nebenKarten,0,0])
                                rotate([0,90,0]) cylinder(d=achseAntrieb,h=abstandSeiten);
                             // das Zahnrad an der Antriebsachse
                            translate([50,0,0]) rotate([0,270,0])
                                gearsbyteethanddistance(t1=uebersetzung[0], t2=uebersetzung[1], d=achseMotorDm, which=0);
                        }
                    }
                    // die Blöcke für die seitliche Befestigung
                    for(x=[-nebenKarten,card.x-breiteBlock+nebenKarten]) translate([x,5,0]) difference(){
                        cube([breiteBlock,10,10]);
                    }
                    // der Halter fuer den Motor
                    difference(){
                        translate([posHalterX,yBase,0]) cube([motorHalter.x,motorHalter.y,achseZ]);
                        // den Motor ausschneiden, etwas verschoben um Toleranzen auszugleichen
                        translate([motorX-2,achseMotorD-achseY,achseZ]) motor();
                        // und die Bohrungen
                        for(y=[yBase+2,yBase+motorHalter.y-2]){
                            translate([posHalterX+motorHalter.x/2,y,achseZ-motorHalterBohrungZ+.1])
                                cylinder(d=motorHalterBohrungD, h=motorHalterBohrungZ);
                        }
                    }
                    // jetzt der Servo-Halter
                    offsetZ = 4;    // wie weit nach oben?
                    translate([20.3,halterY+9.5,11.2+offsetZ])rotate([0,0,180]) holder9g();
                    // das Stueck unter dem Halter wird aufgefuellt
                    translate([5.5,halterY,0]) cube([26.6,3,offsetZ+10]);
                }
                // die Löcher fuer die Achse ohne Lager
                //translate([0,-achseY,achseZ]) rotate([0,90,0]) cylinder(d=achseAntrieb+.3,h=card.x); // eine Achse ohne Lager
                // die Löcher für die Achse größer, die Führung macht das Lager
                translate([0,-achseY,achseZ]) rotate([0,90,0]) cylinder(d=achseAntrieb+1,h=card.x);
                // die beiden Löcher für die Lager
                for(pos=[abstandSeitenX-.1,card.x-abstandSeitenX-3+.1])
                    translate([pos,-achseY,achseZ]) rotate([0,90,0])
                        cylinder(d=bearingOuterDiameter(683)+.2,h=bearingWidth(683)+.2);
            }
            if(maleAntrieb){
                translate([motorX,achseMotorD-achseY,achseZ]){
                    motor();
                    // das Zahnrad am Motor
                    translate([27,0,0])rotate([0,270,0])
                        gearsbyteethanddistance(t1=uebersetzung[0], t2=uebersetzung[1], d=achseMotorDm, which=1);
                }
            }
        }
        // jetzt die Löcher
        langloch=9; // zur Befestigung am Kartenhalter
        for(pos=[bohrungHalterX+.25,card.x-bohrungHalterX]){
            translate([pos,langloch/2,0])
                slotM3(laenge=langloch,dicke=auflageD);
        }
        // die seitliche Befestigung
        for(x=[-nebenKarten,card.x-breiteBlock+nebenKarten]){
            translate([-.1+x,10,5]){
                rotate([0,90,0])cylinder(d=3.5, h=breiteBlock+.2,$fn=25);
            }
            translate([bM3+x,10,5])rotate([0,90,0])tascheM3();
        }
        // das Motokabel wird zum Servo-Kabel gezogen
        dKabel = 2.5;
        lochY = motorHalter.y+3+.3;
        #translate([posHalterX+motorHalter.x-dKabel/2,yBase+lochY-.1,dKabel+auflageD])
            rotate([90,0,0])cylinder(h=lochY,d=dKabel,$fn=25);
        translate([posHalterX+motorHalter.x+.1,yBase+dKabel/2,dKabel+auflageD])
            rotate([0,270,0])cylinder(h=motorHalter.x+.2,d=dKabel,$fn=25);
    }
}

module motor(){
    achseX = 10;
    motorX = 25;    // davon 9mm Getriebe
    hubbelZ = 5;
    color("Gray") difference(){
        rotate([0,90,0]) union(){
            // der Motor
            cylinder(d=motorZ,h=motorX,center=true);
            // das Getriebe
            translate([0,0,8]) cube([10,12,9],center=true);
            // die Antriebsachse
            translate([0,0,motorX/2+achseX/2]) cylinder(d=2,h=achseX,center=true);
            // der Hubbel auf der Anschlusseite ist 1mm dick
            translate([0,0,-motorX/2]) cylinder(d=hubbelZ,h=2,center=true);
        }
        // oben und unten abgeflacht
        translate([-motorX/2-.1,-5,5]) cube([motorX+.2,10,10]);
        translate([-motorX/2-.1,-5,-15]) cube([motorX+.2,10,10]);
    }
}

// dies hier muss nach dem Drucken bearbeitet werden
// -mit einem M3 Gewindeschneider die Madenschrauben 
// -die Achse mit 3mm bohren
module antriebsRad(){
    difference(){
        // da hier das Gummi läuft, wird feiner aufgelöst
        union(){
            cylinder(d=rolleObenD, h=rolleObenB, $fn=80);
            // auf der Innenseite eine Führung für das Gummi
            cylinder(d1=rolleObenD+2,d2=rolleObenD, h=1, $fn=80);
        }
        
        // das Loch fuer die Achse
        translate([0,0,-.1]) cylinder(d=achseAntrieb+.2,h=rolleObenB+.2,$fn=15);
        // in der Fläche wird etwas weggenommen um die Reibung zu verringern
        aussparung=3; // wieviel wird aus der Fläche weggenommen
        translate([0,0,rolleObenB-aussparung+.1]) difference(){
            cylinder(d=rolleObenD-3,h=aussparung);
            // um die Achse herum wieder mit voller Stärke auch um die Madenschraube zu halten
            cylinder(d=achseAntrieb+11,h=aussparung);
        }
        // die Madenschraube zur Fixierung
        bohrungD=2.9;
        dZ=.5;  // etwas aus der Mitte verschoben um stabiler zu werden
        translate([0,0,rolleObenB/2+dZ])rotate([0,105,0])cylinder(d=bohrungD, h=20, $fn=15);
    }
}

module motorKlemme(){
    // besteht aus einem Block von dem ein halber Motor abgezogen wird
    difference(){
        cube([motorHalter.x,motorHalter.y,motorZ-4]);   // 4mm weniger um Material zu sparen
        translate([4,motorHalter.y/2,0]) motor();       // der Motor
        // und die Befestigungen
        for(y=[2,motorHalter.y-2]){                     // jeweils 2mm vom Rand entfernt
            translate([motorHalter.x/2,y,-.1])
            cylinder(d=motorHalterBohrungD+.5, h=motorZ);
        }
    }
}

module bothGears(){
    //$fn=100;    // die hohe Auflösung ist fürs SLA drucken gedacht
    translate([25,0,0])
        gearsbyteethanddistance(t1=uebersetzung[0], t2=uebersetzung[1], d=achseMotorDm, which=0);
    translate([0,0,0])
        gearsbyteethanddistance(t1=uebersetzung[0], t2=uebersetzung[1], d=achseMotorDm, which=1 /*das erste*/);
}

module anpressrolle(){
    // die Löcher der Antriebsachse muessen mit 3mm nachgebohrt werden
    // schwierig zu drucken weil Support über gedrucktem Material notwendig ist.
    // jetzt PrusaMK3, organic
    // mit Cura hochkant, dort ist aber der Support zu stabil. MakerBot hat gut funktioniert
    // die Drehachse ist die Antriebsachse
    difference(){
        union(){
            rotate([135,0,0]){
                union(){
                    // jetzt die Querachse, die die Kugellager haelt
                    anpressachseY=bearingInnerDiameter(model=625);           // auf die Achse soll das Kugellager
                    ueberhang = 3;                      // haelt das Gummi auf der Rolle
                    anpressachseZ=bearingOuterDiameter(model=625)/2+3;      // Breite der horizontalen Stuecke jeweils
                    verschiebungZ = bearingOuterDiameter(model=625)/2+10;   // Abstand Drehachse/Kugellager 
                    posZ = rolleObenD/2+verschiebungZ/2-anpressachseY/2;
                    // der horizontale Teil zwischen den Kugellagern
                    x=card.x-2*KL625frei;
                    translate([KL625frei,0,posZ]){
                        cube([x,anpressachseZ+ueberhang,anpressachseY]);
                    }
                    // der Arm, der die Karten separieren soll
                    separierer = [8,13];
                    translate([(card.x-separierer.x)/2,-separierer.y,posZ]) union(){
                        cube([separierer.x,separierer.y,anpressachseY]);
                        translate([0,0,-(bearingOuterDiameter(model=625)-anpressachseY)/2])
                            cube([separierer.x,3,bearingOuterDiameter(model=625)/2]);
                    }
                    // der breite horizontale Teil
                    translate([-nebenKarten,anpressachseZ,0]){
                        translate([0,0,posZ])
                            cube([abstandSeiten,anpressachseZ+ueberhang,anpressachseY]);
                        // die Arme zur Verbindung mit der Drehachse
                        eckeZ=5;    //die Verstärkung der Ecken
                        eckeX=5;
                        laenge = anpressachseZ+ueberhang;
                        translate([0,0,posZ+.1])rotate([-90,0,0])
                            linear_extrude(height=laenge, convexity = 10)
                                polygon(points=[[0,0],[eckeX,0]
                                    ,[armServorolleD,eckeZ],[0,eckeZ]]);
                        translate([abstandSeiten-anpressachseY+5,laenge,posZ+.1])
                            rotate([90,180,0])
                                linear_extrude(height=laenge+.1, convexity = 10)
                                    polygon(points=[[0,0],[eckeX,0]
                                        ,[armServorolleD,eckeZ],[0,eckeZ]]
                                        , paths=[[0,1,2,3]]);
                    }
                    armBreite=14;   // so breit, das es in allen Stellungen zwischen
                                    // Seite und Antriebsrad bleibt
                    armLaenge=36;   // optisch angepasst
                    for(x=[-nebenKarten,-nebenKarten+abstandSeiten-armServorolleD]){
                        rotate([-45,0,0]) translate([x,-armBreite/2,0])
                            difference(){
                                union(){
                                    // der Arm aus Rechteck + Kreis
                                    difference(){
                                        cube([armServorolleD,armBreite,armLaenge]);
                                        // die unnuetze Ecke gegenüber der Kugellager
                                        translate([-.1,16.3,armLaenge-10])
                                            rotate([45,0,0])
                                                cube([armServorolleD+.2,8,20]);
                                    }
                                    translate([0,armBreite/2,0]) rotate([0,90,0])
                                        cylinder(d=armBreite,h=armServorolleD);
                                }
                                // die Achse
                                translate([-.1,armBreite/2,0]) rotate([0,90,0])
                                    cylinder(d=achseAntrieb+.1,h=armServorolleD+.2,$fn=25);
                            }
                    }
                    // die Arme und der Querbügel für die Servo-Ansteuerung
                    rotate([45,0,0]){
                        servoarmY=8;
                        servoarmZ=18;   // die Länge des Hebels
                        translate([-nebenKarten,-servoarmY/2,-servoarmZ-5]){
                            for(x=[0,abstandSeiten-armServorolleD]){
                                translate([x,0,0])
                                    cube([armServorolleD,servoarmY,servoarmZ]);
                            }
                            // die horizontale Verbindung der beiden Servoarme
                            cube([abstandSeiten,servoarmY,armServorolleD]);
                            // die Befestigung des Hebels
                            translate([abstandSeiten/2-5,0,0])rotate([-45,0,0])
                                difference(){
                                    c = [6,3,3];
                                    cube(c);
                                    translate([c[0]/2,c[1]/2,-.1])cylinder(d=2, h=3);
                                }
                        }
                    }

                    translate([0,0,rolleObenD/2+verschiebungZ/2]){
                        rotate([0,90,0]){
                            cylinder(d=bearingInnerDiameter(model=625),h=card.x); // die Achse
                            // die Kugellager
                            for(pos=[auflageD,card.x-auflageD]){
                                %color("Gray")translate([0,0,pos-bearingWidth(model=625)/2]) bearing(model=625);
                            }
                        }
                    }
                }
            }
        }
    }
}

stuetzeZ=30;            // die Hoehe der Stütze ohne Überlappung, war 25
ueberlappungRB=10;      // hier wird der Halter an den DokoRo geschraubt
stuetzeXmax=stuetzeZ+ueberlappungRB;

module raspbiHalter(){
    tiefeHalter=6;
    offsetX=22;         // hier fängt der Halter an
    halterX=60;         // die PCB-Clips aussen, bestimmt durch pibase()
    halterY=117;        // gemessen
    difference(){
        union(){
            // die z=0 Achse liegt auf der Unterkante der Platine
            translate([13,(abstandSeiten-halterX)/2,0]){
                %translate([-15,0,0])piboard();          
                pibase();
            }
            translate([0,0,-tiefeHalter]){  //Koordinatensystem auf die ausseren Punkte
                //Vorderkante und Hinterkante
                translate([-offsetX,0,0]) einRaspbiHalterPaar(1);  // hier kommt der Kamerahalter hin
                translate([seitenwand.x-offsetX-breiteStuetzeRB,0,0]) einRaspbiHalterPaar(0);

                //Verstärkung an den Längsseiten
                for(y=[-5,abstandSeiten-9]) translate([-offsetX,y,0]) 
                    cube([seitenwand.x,10,2]);
            }
        }
    }
}

module einRaspbiHalterPaar(mitMutter){
    bodenD=2;
    difference(){
        union(){
            // die kurzen Verbindungen zwischen 2 Stützen
            translate([0,-2,0]) cube([14,abstandSeiten,bodenD]);
            eineRaspiStuetze(mitMutter);
            translate([0,abstandSeiten-4,0]) mirror([0,1,0]) eineRaspiStuetze(mitMutter);
        }
    }
}

module eineRaspiStuetze(mitMutter){
    stuetzeD=3;                         // Rasbihalter unterhalb der Seitenplatte
    difference(){ union(){
            // der kurze Teil der Senkrechten
            translate([0,-5,0]) cube([breiteStuetzeRB,stuetzeD,stuetzeZ]);
            // der lange Teil der Senkrechten
            translate([0,-2,0]) cube([breiteStuetzeRB,RBueberlappungD,stuetzeXmax]);
            if(mitMutter){
                ueberlappung = 5;
                translate([0,0,stuetzeZ-ueberlappung]) difference(){
                    z=RBueberlappung+ueberlappung;
                    //cube([breiteStuetzeRB,stuetzeD,z]);
                    translate([breiteStuetzeRB,0,0]) rotate([0,270,0])
                        linear_extrude(height = breiteStuetzeRB, convexity = 10)
                            polygon(points=[[0,0],[z,0],[z,3],[5,3] ]
                                , paths=[[0,1,2,3]]);
                    
                    translate([breiteStuetzeRB/2,stuetzeD+.1,RBueberlappung]) rotate([90,0,0])
                        cylinder(d=6.5,h=stuetzeD+.2, $fn=6);   // die Mutter, todo ausmessen
                }
            }
        }
        // jetzt das Loch. auf der Kameraseite Durchgang zum Kamerahalter, vorne Durchgang zur Mutter
        translate([breiteStuetzeRB/2,-RBueberlappungD-.1,stuetzeXmax-ueberlappungRB/2])
            rotate([0,90,90]) cylinder(d=holeM3,h=stuetzeD+.1); 
    }
}

module kameraHalter(){
    //besteht aus 2 Teilen
    mitKamera = 1;      // eventuell will man nur den unteren Teil drucken
    
    // horizontale Verbindung zwischen den Raspbi Befestigungspunkten
    fix = [abstandSeiten-2*RBueberlappungD,breiteStuetzeRB,8];     // dieses wird am Gerät festgeschraubt
 
    difference(){
        cube(fix);
        translate([-.1,breiteStuetzeRB/2,fix[2]/2]) rotate([0,90,0]){
            // die Löcher für die Befestigung
            cylinder(d=holeM3,h=fix[0]+.2, $fn=25);
            // die Taschen für die Muttern
            for(i=[4,fix[0]-4-bM3]) translate([0,0,i])tascheM3();
        }
    }
    arm = [8,50,6];     // Dicke, Länge, Höhe des unteren doppelten Arms
    gap = .25;          // zwischen den Arm-Teilen, nur fürs drucken, war .3
    translate([fix[0]/2,0,0])difference(){
        union(){
            for(pos=[-arm[0]*1.5-gap,arm[0]*.5+gap]) translate([pos,0,0]) cube(arm);
            
            if(mitKamera){
                translate([0,arm[1]-arm[0],0]){
                    arm2 = [arm[0],50,arm[2]];    // dann der Arm an dem die Kamera hängt
                    translate([-arm2[0]/2,0,0]) cube(arm2);

                    // das eigentliche Kamera-Gehäuse
                    translate([0,arm[1]+15,0]) rotate([0,0,180]) piCameraAdapter();
                }
            }
        }
        // das Loch für die Schraube zur Fixierung der beiden Arme
        translate([0,arm[1]-arm[0]/2,arm[2]/2]){
            translate([-fix[0]/2,0,0])rotate([90,0,90]) cylinder(d=holeM3, h=fix[0], $fn=25);
            // aus einer Seite wird eine Mutter eingesetzt
            translate([-arm[0]*1.5-gap-.1,0,0]) rotate([0,90,0])
                cylinder(d=5.8, h=bM3+.2, $fn=6); // d war 6
        }
    }
}

module spielkarte(){
    color("white") cube(cardRaw);
}

// jetzt malen
if(paintAll3D){
    pos = $t;   // durch Setzen von Zahlen 0-1.0 bestimmte Positionen anzeigen lassen
    // ein Wert zwischen 0 und 1 wärend der Phase
    actMove1=min(pos,t_cardUp)/t_cardUp;
    echo (str("actMove1=", actMove1));
    actDrehung = min(max(0,pos-t_cardUp)/(t_drehung-t_cardUp),1);
    echo (str("actDrehung=", actDrehung));
    actMove2 = max(0,(min(pos,t_cardUp2)/(t_cardUp2)-t_cardUp2)/(1-t_cardUp2));
    echo (str("actMove2=", actMove2));
    actFall = max(0,pos-t_cardUp2)/(1-t_cardUp2);
    echo(str("actFall=", actFall));

    for(pos=[seitenwand.z,abstandSeiten+2*seitenwand.z]){
        translate([pos,seitenwand.x,-20]) rotate([90,0,-90]) seitenwand();
    }
    // an den Seitenwänden wird die Kartenauflage und die gesamte Mechanik befestigt
    translate([seitenwand.z,35.5-swAddY,-auflageD/2+5]) rotate([45,0,0])
        union(){    // die Kartenauflage mit allem was daran hängt
            cardholder();
            translate([armServorolleD,0,0]) halterUnten();
            translate([0,-.2,-4.5]) rotate([0,90,0]) scheibeHalterUnten();
            translate([abstandSeiten-0.7,-.2,-4.5])rotate([0,-90,0]) scheibeHalterUnten();
            translate([19,66,-16]) rotate([0,180,0]){
                motor9g(180+actDrehung*90);
            }
            translate([armServorolleD,90,0]) rotate([180,0,0]){
                halterOben(1);  // mit Antrieb
                // die Position ist per Hand angepasst
                translate([17,-5,16+1]) motorKlemme();  // mit etwas Spiel
                //die Animation soll sich hin und her bewegen
                translate([0,-13,16]) rotate([45,0,0]) {
                    rotate([-actDrehung*45,0,0]) union(){
                        anpressrolle();
                        // die Karte bewegt sich mit der Rotation
                        rotate([-45,0,0]) translate([0,9,-22])
                            translate([0,-95*actMove1+85*actMove2+25*actFall,0]) 
                                rotate([actFall*45,0,0])spielkarte();
                    }
                }
            }
        }
        translate([abstandSeiten+1,22,-44.5]) rotate([0,0,90]) raspbiHalter();
        // jetzt die Kamera
        translate([abstandSeiten+1,seitenwand.x-breiteStuetzeRB,-18]) rotate([-45,180,0]){
            kameraHalter();
            translate([abstandSeiten/2-2,98,14]) piCameraBackCover(-0.2);	// der Schiebedeckel
        }
}

if(paintAll2D){
    kerf = .2;   // dies nimmt der Laser an Materialbreite weg
    offset(delta=kerf/2){
        projection() {
            /*rotate([0,180,0])*/seitenwand();
        }
    }
}