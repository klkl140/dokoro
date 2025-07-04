// der DoppelKopfRoboter
// (c) Klaus Kloos 160630
//
// die 0-Achse liegt in der Mitte der horizontalen Winkelverstellung

use <pibase.scad>               // board und halter
use <kugellager.scad>
use <ParametricHerringboneGears.scad>
use <servo9g.scad>
use <Font/font_DesignerBlock_lo.scad>
use <CameraAdapter.scad>        // fuer die Raspberry-Kamera
use <ISOThreadCust.scad>

// neu, noch nicht gedruckt
// -die Bohrung für die Befestigung der Zahnraeder von 3mm auf 2.4mm
// -Bohrungen in den Seitenflächen zur Befestigung der Basis größer
// -die Bohrungen im cardholder von 3 auf 3.5
// -die gesenkten Bohrungen jetzt mit hoeherer Aufloesung
//
// was fehlt noch?
// -Kabelbefestigung
//
// was soll gemalt werden?
paintAll3D = 1;                         // alles an ihrer Positionen evtl mit Animation
paintAll2D = 0;                         // dies kann mit einem Laser gemacht werden

if(!paintAll3D){         // hier kommen die einzelnen Teile für die Fertigung
    //seitenwand();						// 2* die Seiten
    //cardholder();                     // kartenauflage, hier liegen die Karten
    //scheibeHalterUnten();             // 2* neben den Kugellagern zur Führung des Gummis
    //rotate([180,0,0]) halterUnten();
    //rotate([0,-180,0]) motorKlemme(); // hiermit wird der Motor befestigt
    //rotate([0,-90,0]) antriebsRad();  // 2* die oberen Antriebsräder
    halterOben(0);                    // ohne Antrieb
    //zahnraeder();                     // beide Zahnräder, fürs Drucken Auflösung einstellen!
    //raspbiHalter();                   // der Halter für den Raspberry
    //anpressrolle();                   // der mit dem Servo bewegte Greifer
    //kameraHalter();                   // Kamera fuer den Blick auf die Karten
	//piCameraBackCover(-0.2);	        // der Schiebedeckel
    //motor();                          // Dummy des Motors, wird nicht benötigt
}

// Animation
t_cardUp = .3;                      // die Zeit in der die Karte nach oben fährt
t_drehung = .5;                     // nach dieser Zeit ist die Drehung fertig
t_cardUp2 = .7;                     // die zweite Bewegung der Karte

// die Definition einer Karte
cardRaw = [59, 90, 0.5];            // eine Spielkarte
cardX = cardRaw[0]+1;               // mit ein wenig Spiel
cardY = cardRaw[1]+3;               // ...

seitenwandD = 3;                    // wie dick soll die Seitenwand sein
seitenwandSchenkel=35;              // die Breite der beiden Schenkel, in der Mitte der Schlitz
seitenwandAddY=5;                   // auf der Seite der Antriebsräder etwas länger für die Schrift
                                    //  und damit der Servohebel geführt wird
seitenwandY = cardY+seitenwandSchenkel/2+seitenwandAddY;

auflageD = 3;                       // cardholder und der obere Halter
breiteStegUnten =15;
KL625innen=5;                       // 625 Kugellagern sind  5*16*5
KL625breite=5;                      //
KL625aussen=16;                     //
KL625frei = KL625breite+1;          // ein wenig Spiel
KL683aussen=7;
KL683breite=3;
rolleObenD = 38;                    // die Antriebsrolle oben
breiteRolleOben = 5;
bohrungHalter = 3.5;                // fuer beide Halter, war 3
bohrungHalterX = 12;                // jeweils der Abstand vom Rand
bohrungHalterUntenY = 10;
bohrungHalterObenY = 81;
abstandAchseMotor=20;               // zwischen Motor und Antriebsachse
achseAntrieb = 3;                   // muss auch in ParametricHerringboneGears eingestellt werden
zahnradX = 14;                      // gear_h+gear_shaft_h in ParametricHerringboneGears
motorHalterY=20;                    // der Bock an dem der Motor befestigt wird
motorHalterX=15;                    // ...
motorHalterBohrung=2.5;             // die Befestigung des oberen Stuecks
motorHalterBohrungZ=5;              // wie tief sollen die Loecher sein?
motorZ = 12;                        // die Dicke des Motors 
breiteStuetzeRB=14;                 // die Stützen des Raspbi-Halters
RBueberlappung=10;                  // Überlappung zwischen Raspbi-Halter und Seitenwand
RBueberlappungD=2;                  // das Material neben der Seitenplatte
armServorolleD=2;
    
//berechnetes
abstandSeiten = cardX+2*armServorolleD+1;   // der Abstand der beiden Seiten auf der Innenseite
                                            // etwas Spiel für die Mechanik, innen gemessen

bM3 = 2.7;      // die Dicke der Mutter, 2.5 war zuwenig
holeM3 = 3.5;   // da passt die Schraube durch
module tascheM3(){
    b=6;        // der Durchmesser für die 6eckige Mutter
    cylinder(d=b, h=bM3, $fn=6);
    b1=b*.9;    // die zur Mutter gehörende Breite
    translate([-10,-b1/2,0])cube([10,b1,bM3]);
}

// eine Bohrung fuer eine gesenkte Schraube
module eineBohrung(bohrung,dicke){
    union(){
        cylinder((dicke+.5)/2, d=bohrung, $fn=15);
        translate([0,0,(dicke+.2)/2])
            cylinder((dicke+.5)/2, r1=bohrung/2, r2=bohrung, $fn=15);
    }
}

module einLanglochM3(dicke, laenge){
    mutterX = 5.5;  // die Mutter soll sich verschieben lassen
    translate([-holeM3/2,0,-.1]) union(){
        //oben soll Platz für die Mutter sein
        translate([0,0,0]) cube([holeM3,laenge,dicke/2+.1]);
        //die andere Hälfte bleibt mit der Bohrung
        translate([-(mutterX-holeM3)/2,0,dicke/2]) cube([mutterX,laenge,dicke/2+.2]);
    }
}

module seitenwand(){
    oberhalbSchlitz=8;
    hSchlitzLaenge=cardY-8;     // jetzt 8mm kürzer, die Achse soll immer frei sein
    halbeSW = seitenwandSchenkel/2;
    hoehe=hSchlitzLaenge+halbeSW+oberhalbSchlitz;    // die lange Seite, vertikal
    laenge=cardY+halbeSW;       // die kurze Seite, horizontal
    schlitz=3;                  // der Schlitz für die Winkelverstellung
    difference(){
        linear_extrude(height = seitenwandD, convexity = 10)
            polygon(points=[[0,0],[seitenwandY,0],[seitenwandY,seitenwandSchenkel]
                        ,[seitenwandSchenkel+seitenwandAddY,seitenwandSchenkel]
                        ,[seitenwandSchenkel+seitenwandAddY,hoehe]
                        ,[0,hoehe]]
                    , paths=[[0,1,2,3,4,5]]);
        translate([15,hSchlitzLaenge-3,-1]) rotate([0,0,90])
            difference(){
                label("dokoro", size=4, height=seitenwandD+2);
                // mit einem Steg fixieren wir die haltlosen Innen-Stücke der Os
                translate([-18,1.8,0]) cube([45,1,seitenwandD+2]);
            }
        // der vertikale, lange Schlitz
        translate([halbeSW+seitenwandAddY,halbeSW,-.1])
            cube([schlitz,hSchlitzLaenge,seitenwandD+.2]);
        // der horizontale, kürzere Schlitz
        translate([seitenwandSchenkel-5+seitenwandAddY,halbeSW,-.1])
            cube([70,schlitz,seitenwandD+.2]);
        // die Löcher für die Befestigung Raspi-Halters
        for(i=[breiteStuetzeRB/2,laenge-breiteStuetzeRB/2+seitenwandAddY]){
            translate([i,RBueberlappung/2,-.1])
                cylinder(d=holeM3,h=seitenwandD+.2, $fn=20);
        }
    }
}

module cardholder(){
    // hier liegen die Karten
    // die Breite des cardholder wird durch abstandSeiten bestimmt
    // neben den eigentlichen Karten soll ein Keil dafür sorgen das die Karten richtig fallen
    // daneben gibt es noch eine Führung für das Gummi
    breiteStege =10;                    // die Seiten
    nebenKarten = (abstandSeiten-cardX)/2;  // die Breite des Keils
    KLlochX = KL625frei+nebenKarten;    // Freiraum Kugellager in Richtung Achse
    KLlochY = 10;                       // Freiraum Kugellager in Richtung Gummies
    union(){
        difference(){
            cube([abstandSeiten, cardY, auflageD]);    // die eigentliche Unterlage
            // die Auschnitte fuer die Rollen mit etwas Spiel
            translate([-.1,-.1,-.1]) cube([KLlochX,KLlochY,auflageD+.2]);   
            translate([abstandSeiten-KLlochX+.1,-.1,-.1])
                cube([KLlochX,KLlochY,auflageD+.2]);
            // in der Mitte braucht es kein Material
            translate([breiteStege,breiteStegUnten,-.1])
                cube([abstandSeiten-2*breiteStege,55,auflageD+.2]);
            // und die Bohrungen fuer den unteren Rollenhalter
            posX=bohrungHalterX+nebenKarten;
            translate([posX,bohrungHalterUntenY,-.1])
                eineBohrung(bohrung=bohrungHalter, dicke=auflageD);
            translate([abstandSeiten-posX,bohrungHalterUntenY,-.1])
                eineBohrung(bohrung=bohrungHalter, dicke=auflageD);
            // und fuer den oberen Rollenhalter
            translate([posX,bohrungHalterObenY,-.1])
                eineBohrung(bohrung=bohrungHalter, dicke=auflageD);
            translate([abstandSeiten-posX,bohrungHalterObenY,-.1])
                eineBohrung(bohrung=bohrungHalter, dicke=auflageD);
        }
        //der untere Kartenhalter
        halterX = abstandSeiten-2*KLlochX;
        translate([(abstandSeiten-halterX)/2,0,0]) cube([halterX,auflageD,25]);
        // die Keile auf den Seiten
        keilZ=15;
        breiteOben = .8;    //nicht zu duenn, wird instabil
        translate([0,cardY,auflageD])
            einKeil(nebenKarten, cardY-KLlochY, keilZ, breiteOben);
        translate([abstandSeiten,KLlochY,auflageD]) rotate([0,0,180])
            einKeil(nebenKarten, cardY-KLlochY, keilZ, breiteOben);
        // dann noch die Führungen des Gummis
        gBreite=4;  // Breite des Gummies
        fuehrungX=2;
        translate([nebenKarten+gBreite+.5,KLlochY,auflageD])
            einKeilFuehrung(fuehrungX,cardY-KLlochY);
        translate([abstandSeiten-(nebenKarten+gBreite+.5),cardY,auflageD])
            rotate([0,0,180]) einKeilFuehrung(fuehrungX,cardY-KLlochY);
    }
}

module einKeil(breite, laenge, hoehe, breiteOben){
    rotate([90,0,0])
        linear_extrude(height=laenge, convexity = 10)
            polygon(points=[[0,0],[breite,0], [breiteOben,hoehe], [0,hoehe]]
                , paths=[[0,1,2,3]]);
}

module einKeilFuehrung(breite,laenge){
    breiteKeil=1;
    gDicke=1;   // das Gummi
    fuehrungZ=gDicke-.2;
    translate([breiteKeil,0,0]) union(){
        rotate([0,0,180]) einKeil(breiteKeil, laenge, fuehrungZ, 0);
        cube([breite-breiteKeil,laenge,fuehrungZ]);
    }
}

module halterUnten(){
    union(){
        platteX = cardX-2*KL625frei;
        translate([KL625frei,-2.5,-auflageD]) 
            difference(){
                // die Platte
                cube([platteX,breiteStegUnten+2.5,auflageD]);
                // die Langloecher fuer die Befestigung unten
                posX = bohrungHalterX-KL625frei;
                langloch=9;
                // der breite Teil muss nach oben, deshalb etwas komplizierter
                translate([0,langloch*1.5+2,auflageD]){
                    translate([posX,0,0]) rotate([180,0,0])
                        einLanglochM3(laenge=langloch,dicke=auflageD);
                    translate([platteX-posX,0,0]) rotate([180,0,0])
                        einLanglochM3(laenge=langloch,dicke=auflageD);
                }
            }
        // die Achse (Position per Hand angepasst)
        dxFuerMitte=(abstandSeiten-cardX)/2;
            translate([-dxFuerMitte,0,-4.6])
            difference(){
                union(){
                    rotate([0,90,0]) cylinder(d=KL625innen,h=abstandSeiten);
                    // und die Verstaerkung
                    translate([KL625frei+dxFuerMitte,-2.5,-.4]) cube([platteX, 5, 5]);
                }
                // das Loch fuer die Befestigung der seitlichen Schrauben
                rotate([0,90,0]) translate([0,0,-.1]) cylinder(d=2.5,h=abstandSeiten+.2);
            }
        
        // die Rollen als Kugellager 625
        %color("Gray") translate([2.5+.5,0,auflageD-KL625aussen/2]){
            rotate([0,90,0]) kugellager625();
            translate([cardX-KL625frei,0,0])
                rotate([0,90,0]) kugellager625();
        }
    }
}

module scheibeHalterUnten(){
    dickeScheiben = (abstandSeiten-cardX)/2;    // etwas Spiel fuer den Arm
    aussenD=KL625aussen+4;                      // etwas größer um das Gummi zu führen
    difference(){
        union(){
            //damit es nicht schleift gibt es innen einen Absatz
            cylinder(d=KL625innen+4,h=dickeScheiben);
            cylinder(d=aussenD,h=dickeScheiben-.5);
        }
        translate([0,0,-.1]) cylinder(d=KL625innen+.5, h=dickeScheiben+.2);
    }
}

module seiteHalterOben(x,y,z){  // die Führung für die oberen Antriebsräder
    difference(){
        cube([x,y,z]);
        // winklig den unnötigen Teil abschneiden
        translate([-.1,-y/2,0]) rotate([-45,0,0]) cube([x+.2,y,23]);
    }
}

module halterOben(maleAntrieb){
    achseZ = rolleObenD/2-auflageD; // die Position der Drehachse
    achseY = 15;                    // Verschiebung in Kartenrichtung
    halterY = 15;                   // Breite des Halters auf der Kartenunterlage
    achseFutter=8;                  // Material um die Achse herum
    motorX = 23;                    // die seitliche Position des Motors
    seiteX = 4;                     // da kommt das 683 Lager hinein
    union(){
        // die Grundplatte
        difference(){
            cube([cardX,halterY,auflageD]);
            langloch=9;
            translate([0,langloch/2,0]){
                translate([bohrungHalterX,0,0])
                    einLanglochM3(laenge=langloch,dicke=auflageD);
                translate([cardX-bohrungHalterX,0,0])
                    einLanglochM3(laenge=langloch,dicke=auflageD);
            }
        }
        // die Seiten, die Befestigung an den Seitenplatten, Antrieb, ...
        difference(){
            abstandSeitenX = breiteRolleOben+.5;  // mit etwas Spiel
            union(){
                breite = achseY+halterY+achseFutter;
                hoehe = achseZ+achseFutter+10;
                translate([0,achseY-breite,0]){
                    translate([abstandSeitenX,0,0])
                        difference(){
                            wegX=2;
                            seiteHalterOben(seiteX,breite,hoehe);
                            //etwas wegschneiden fuer den Motoranschluss
                            translate([seiteX-wegX+.1,22,5]) cube([wegX,14,hoehe-8]);
                        }
                    translate([cardX-seiteX-abstandSeitenX,0,0])
                        seiteHalterOben(seiteX,breite,hoehe);
                }
                if(maleAntrieb){
                    translate([0,-achseY,achseZ]){
                        // die Rollen, die Aussparung ist aussen
                        translate([breiteRolleOben,0,0])rotate([0,0,180]) antriebsRad();
                        translate([cardX-breiteRolleOben,0,0])antriebsRad();
                        // die Achse
                        %translate([-(abstandSeiten-cardX)/2,0,0])
                            rotate([0,90,0]) cylinder(d=achseAntrieb,h=abstandSeiten);
                         // das Zahnrad an der Antriebsachse
                        translate([50,0,0]) rotate([0,270,0])
                            gearsbyteethanddistance(t1=15, t2=15, d=abstandAchseMotor, which=1);
                    }
                }
                // und die beiden Blöcke und Schraubenloecher fuer die seitliche Befestigung
                leerX=(abstandSeiten-cardX)/2;  // hier liegt der Servo-Arm
                breiteBlock=abstandSeitenX+leerX;
                for(x=[-leerX,cardX-breiteBlock+leerX]) translate([x,5,0]) difference(){
                    cube([breiteBlock,10,10]);
                    translate([-.1,5,5]) rotate([0,90,0]) cylinder(d=2.5, h=breiteBlock+.2);
                }
                // der Halter fuer den Motor
                difference(){
                    posHalterX = 17;
                    yBase = -(motorHalterY-halterY);    // hier liegt die eine Seite der Motorbefestigung
                    translate([posHalterX,yBase,0]) cube([motorHalterX,motorHalterY,achseZ]);
                    // den Motor ausschneiden, etwas verschoben um Toleranzen auszugleichen
                    translate([motorX-2,abstandAchseMotor-achseY,achseZ]) motor();
                    // und die Bohrungen
                    translate([posHalterX+motorHalterX/2,0,achseZ-motorHalterBohrungZ+.1]){
                        translate([0,yBase+2,0])
                            cylinder(d=motorHalterBohrung, h=motorHalterBohrungZ);
                        translate([0,yBase+motorHalterY-2,0])
                            cylinder(d=motorHalterBohrung, h=motorHalterBohrungZ);
                    }
                }
                // jetzt der Servo-Halter
                offsetZ = 4;    // wie weit nach oben?
                translate([17.2,halterY+9.5,11.2+offsetZ])rotate([0,0,180]) holder9g();
                // das Stueck unter dem Halter wird aufgefuellt
                translate([2.4,halterY,0]) cube([29.6,3,offsetZ+10]);
            }
            // die Löcher fuer die Achse ohne Lager
            //translate([0,-achseY,achseZ]) rotate([0,90,0]) cylinder(d=achseAntrieb+.3,h=cardX); // eine Achse ohne Lager
            // die Löcher für die Achse größer, die Führung macht das Lager
            translate([0,-achseY,achseZ]) rotate([0,90,0]) cylinder(d=achseAntrieb+1,h=cardX);
            // die beiden Löcher für die Lager
            lochAussen=KL683aussen+.2;
            tiefe = KL683breite+.2;
            translate([abstandSeitenX-.1,-achseY,achseZ]) rotate([0,90,0])
                cylinder(d=lochAussen,h=tiefe);
            translate([cardX-abstandSeitenX-3+.1,-achseY,achseZ]) rotate([0,90,0])
                cylinder(d=lochAussen,h=tiefe);
        }
        if(maleAntrieb){
            translate([motorX,abstandAchseMotor-achseY,achseZ]){
                motor();   // der Motor
                // das Zahnrad am Motor
                translate([27,0,0]) rotate([0,270,0])
                    gearsbyteethanddistance(t1=15, t2=15, d=abstandAchseMotor, which=0);
            }
        }
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
    rotate([0,90,0]) difference(){
        // da hier das Gummi läuft, wird feiner aufgelöst
        cylinder(d=rolleObenD, h=breiteRolleOben, $fn=80);
        
        // das Loch fuer die Achse
        translate([0,0,-.1]) cylinder(d=achseAntrieb+.2,h=breiteRolleOben+.2,$fn=15);
        // in der Fläche wird etwas weggenommen um die Reibung zu verringern
        aussparung=2.8; // wieviel wird aus der Fläche weggenommen
        translate([0,0,breiteRolleOben-aussparung+.1]) difference(){
            cylinder(d=rolleObenD-3,h=aussparung);
            // um die Achse herum wieder mit voller Stärke auch um die Madenschraube zu halten
            cylinder(d=achseAntrieb+11,h=aussparung);
        }
        // die Madenschraube zur Fixierung
        bohrungD=2.9;
        dZ=.5;  // etwas aus der Mitte verschoben um stabiler zu werden
        translate([0,0,breiteRolleOben/2+dZ])rotate([0,105,0])cylinder(d=bohrungD, h=20, $fn=15);
    }
}

module motorKlemme(){
    // besteht aus einem Block von dem ein halber Motor abgezogen wird
    difference(){
        cube([motorHalterX,motorHalterY,motorZ-4]);     // 4mm weniger um Material zu sparen
        translate([4,motorHalterY/2,0]) motor();        // der Motor
        // und die Befestigungen
        translate([motorHalterX/2,0,-.1]){
            for(y=[2,motorHalterY-2])   // jeweils 2mm vomm Rand entfernt
                translate([0,y,0]) cylinder(d=motorHalterBohrung+.5, h=motorZ);
        }
    }
}

module zahnraeder(){
    // die hohe Auflösung ist fürs SLA drucken gedacht
    translate([25,0,0]) gearsbyteethanddistance(t1=15, t2=15, d=abstandAchseMotor, which=0/*, $fn=100*/);
    translate([0,0,0]) gearsbyteethanddistance(t1=15, t2=15, d=abstandAchseMotor, which=1/*, $fn=100*/);
}

module anpressrolle(){
    // schwierig zu drucken weil Support über gedrucktem Material notwendig ist.
    // Jetzt mit Cura hochkant, dort ist aber der Support zu stabil. MakerBot hat gut funktioniert
    // die Drehachse ist die Antriebsachse
    difference(){
        union(){
            rotate([135,0,0]){
                union(){
                    // jetzt die Querachse, die die Kugellager haelt
                    anpressachseY=KL625innen;           // auf die Achse soll das Kugellager
                    ueberhang = 3;                      // haelt das Gummi auf der Rolle
                    anpressachseZ=KL625aussen/2+3;      // Breite der horizontalen Stuecke jeweils
                    verschiebungZ = KL625aussen/2+10;   // Abstand Drehachse/Kugellager 
                    posZ = rolleObenD/2+verschiebungZ/2-anpressachseY/2;
                    // der horizontale Teil zwischen den Kugellagern
                    x=cardX-2*KL625frei;
                    translate([KL625frei,0,posZ]){
                        cube([x,anpressachseZ+ueberhang,anpressachseY]);
                    }
                    // der Arm, der die Karten separieren soll
                    separiererX = 8;
                    separiererY = 13;
                    translate([(cardX-separiererX)/2,-separiererY,posZ]) union(){
                        cube([separiererX,separiererY,anpressachseY]);
                        translate([0,0,-(KL625aussen-anpressachseY)/2])
                            cube([separiererX,3,KL625aussen/2]);
                    }
                    // der breite horizontale Teil
                    verschiebungX = -(abstandSeiten-cardX)/2;
                    translate([verschiebungX,anpressachseZ,0]){
                        translate([0,0,posZ])
                            cube([abstandSeiten,anpressachseZ+ueberhang,anpressachseY]);
                        // die Arme zur Verbindung mit der Drehachse
                        eckeZ=8;    //die Verstärkung der Ecken
                        eckeX=5;
                        laenge = anpressachseZ+ueberhang;
                        translate([0,0,posZ+.1])rotate([-90,0,0])
                            linear_extrude(height=laenge, convexity = 10)
                                polygon(points=[[0,0],[eckeX,0]
                                    ,[armServorolleD,eckeZ],[0,eckeZ]]
                                    , paths=[[0,1,2,3]]);
                        translate([abstandSeiten-anpressachseY+eckeX,laenge,posZ+.1])
                            rotate([90,180,0])
                                linear_extrude(height=laenge+.1, convexity = 10)
                                    polygon(points=[[0,0],[eckeX,0]
                                        ,[armServorolleD,eckeZ],[0,eckeZ]]
                                        , paths=[[0,1,2,3]]);
                    }
                    armBreite=14;   // so breit, das es in allen Stellungen zwischen
                                    // Seite und Antriebsrad bleibt
                    armLaenge=36;   // optisch angepasst
                    for(x=[verschiebungX,verschiebungX+abstandSeiten-armServorolleD]){
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
                    // und die Arme und der Querbügel für die Servo-Ansteuerung
                    rotate([45,0,0]){
                        servoarmY=8;
                        servoarmZ=18;   // die Länge des Hebels
                        translate([verschiebungX,-servoarmY/2,-servoarmZ-5]){
                            for(x=[0,abstandSeiten-armServorolleD]){
                                translate([x,0,0])
                                    cube([armServorolleD,servoarmY,servoarmZ]);
                            }
                            // die horizontale Verbindung der beiden Servoarme
                            translate([0,0,0])
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
                            cylinder(d=KL625innen,h=cardX); // die Achse
                            %color("Gray"){                  // die Kugellager
                                translate([0,0,auflageD]) kugellager625();
                                translate([0,0,cardX-auflageD]) kugellager625();
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
                translate([seitenwandY-offsetX-breiteStuetzeRB,0,0]) einRaspbiHalterPaar(0);

                //Verstärkung an den Längsseiten
                for(y=[-5,abstandSeiten-9]) translate([-offsetX,y,0]) 
                    cube([seitenwandY,10,2]);
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
    // horizontale Verbindung zwischen den Raspbi Befestigungspunkten
    mitKamera = 1;      // eventuell will man nur den unteren Teil drucken
    mitMetrisch = 1;    // sonst Holzschrauben
    
    fix = [abstandSeiten-2*RBueberlappungD,breiteStuetzeRB,8];     // dieses wird am Gerät festgeschraubt
 
    difference(){
        cube(fix);
        holeD = mitMetrisch?holeM3:2.5;     // die Löcher für die Befestigung
        fn = mitMetrisch?25:6;
        translate([-.1,breiteStuetzeRB/2,fix[2]/2]) rotate([0,90,0]){
            cylinder(d=holeD,h=fix[0]+.2, $fn=fn);
            if(mitMetrisch){    // die Taschen für die Muttern
                for(i=[4,fix[0]-4-bM3]) translate([0,0,i])tascheM3();
            }
        }
    }
    arm = [8,50,6];     // Dicke, Länge, Höhe des unteren doppelten Arms
    gap = .25;          // zwischen den Arm-Teilen, nur fürs drucken, war .3
    translate([fix[0]/2,0,0])difference(){
        union(){
            translate([-arm[0]*1.5-gap,0,0]) cube(arm);
            translate([arm[0]*.5+gap,0,0])   cube(arm);

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
    translate([seitenwandD,seitenwandY,-20]) rotate([90,0,-90]) seitenwand();
    translate([abstandSeiten+2*seitenwandD,seitenwandY,-20]) rotate([90,0,-90]) seitenwand();
    // an den Seitenwänden wird die Kartenauflage und die gesamte Mechanik befestigt
    translate([seitenwandD,35.5-seitenwandAddY,-auflageD/2+5]) rotate([45,0,0])
        union(){    // die Kartenauflage mit allem was daran hängt
            cardholder();
            translate([armServorolleD,0,0]) halterUnten();
            translate([0,-.2,-4.5]) rotate([0,90,0]) scheibeHalterUnten();
            translate([abstandSeiten-0.7,-.2,-4.5])rotate([0,-90,0]) scheibeHalterUnten();
            translate([19,66,-9]) rotate([0,180,0]){
                motor9g();
                arm9g(laenge=20,winkel=180);
            }
            translate([armServorolleD,90,0]) rotate([180,0,0]){
                halterOben(1);  // mit Antrieb
                // die Position ist per Hand angepasst
                translate([17,-5,16+1]) motorKlemme();  // mit etwas Spiel
                //die Animation soll sich hin und her bewegen
                translate([0,-13,16]) rotate([45,0,0]) {
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
        translate([abstandSeiten+1,seitenwandY-breiteStuetzeRB,-18]) rotate([-45,180,0]){
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
    