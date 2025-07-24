// dies hier ist obsolete
// bitte MCAD/servos.scad verwenden

drehachseR = 2.35;
servoX = 23;
servoY = 12.5;
servoZ = 22.5;

offsetBefestigungZ=4;   // wie weit ist die Unterkante der Befestigungsplatte von der Mittelachse entfernt
befestigungZ = 2.7;

module motor9g(winkel=undef,armlaenge=20){
	difference(){			
		union(){
			color("Gray") cube([servoX,servoY,servoZ], center=true);
			befestigungZ = 2.7;
            color("Gray") translate([0,0,offsetBefestigungZ+befestigungZ/2])
                cube([32,12,befestigungZ], center=true);
			color("Gray") translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=30, center=true);
			color("Gray") translate([-.5,0,2.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("Gray") translate([-1,0,2.75]) cube([5,5.6,24.5], center=true);		
			color("white") translate([5.5,0,3.65]) cylinder(r=2.35, h=29.25, $fn=20, center=true);
		}
		// die Abschrägung gibt es nicht immer
        //translate([10,0,-11]) rotate([0,-30,0]) cube([8,13,4], center=true);
		for ( hole = [14,-14] ){
			translate([hole,0,5]) cylinder(r=2.2, h=4, $fn=20, center=true);
		}
	}
    if(winkel!=undef){
        arm9g(armlaenge,winkel);
    } 
}

module arm9g(laenge,winkel){
    armD = 3;
    dhFix = 2;  // die zusätzliche Höhe an der Befestigung
    rAchse = 4;
    rEnde = 2;
    translate([5.4,0,15+dhFix])rotate([0,0,winkel]){
        difference(){
            color("white")union(){
                translate([0,0,-dhFix]) cylinder(r=rAchse, h=armD+dhFix, $fn=25);
                linear_extrude(height = armD, convexity = 10)
                    polygon(points=[[0,rAchse],[0,-rAchse],[laenge,rEnde],[laenge,-rEnde]]
                        , paths=[[0,1,3,2]]);
                translate([laenge,0,0]) cylinder(r=rEnde, h=armD, $fn=20);
            }
            // die Achse
            translate([0,0,-dhFix-.1]) cylinder(r=drehachseR, h=dhFix, $fn=20);
            translate([0,0,-.2]) cylinder(d=2.5, h=armD+.3, $fn=20);
            // das Loch zur Befestigung der Hebelstange
            translate([laenge,0,-.1]) cylinder(d=1.5, h=armD+.2, $fn=20);
        }
    }
}

module holder9g(){
    luft = .3;
    dicke = 3;
    hoehe = servoZ; // der Halter ist so hoch wie das Servo
    naseY = 3.3;    // soll etwas unter Spannung sein, war 3.5
    difference(){
        union(){
            // lange Seite
            translate([-servoX/2-luft,servoY/2+luft,servoZ/2-hoehe])
                cube([servoX+2*luft,dicke,hoehe]);
            // kurze Seiten
            seiteY = servoY+dicke+luft+naseY-1; // jetzt 1mm kürzer
            hoeheS=hoehe-7; //die Federklammern sind auf der ganzen Höhe zu fest.
                            //das Kabel muss auch raus geführt werden
            for(x=[-servoX/2-dicke-luft, servoX/2+luft]){
                translate([x,-servoY/2-naseY+1,servoZ/2-hoeheS]) cube([dicke,seiteY,hoeheS]);
            }
            // die Haltenasen
            dicke2=dicke*.9;   // war 1.1
            for(x=[servoX/2+luft,-servoX/2-luft]){
                //Y jetzt 1mm kuerzer (+1)
                translate([x,-servoY/2-naseY+1,servoZ/2-hoeheS])
                    rotate([0,0,45]) cube([dicke2,dicke2,hoeheS]);
            }
        }
        // der Schlitz für die Befestigung
        schlitzZ = befestigungZ+luft;
        schlitzY = servoY+naseY+.1;
        gesamtX = servoX+2*luft+2*dicke;
        gesamtY = dicke+luft+servoY+naseY;
        translate([-gesamtX/2-.1,-schlitzY+servoY/2,offsetBefestigungZ])
            cube([gesamtX+.2,schlitzY,schlitzZ]);
    }
}

//motor9g();
motor9g(armlaenge=20,winkel=90);
//arm9g(laenge=20,winkel=90);
//holder9g();
