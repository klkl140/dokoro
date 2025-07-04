drehachseR = 2.35;
servoX = 23;
servoY = 12.5;
servoZ = 22.5;

offsetBefestigungZ=4;   // wie weit ist die Unterkante der Befestigungsplatte von der Mittelachse entfernt
befestigungZ = 2.7;

module motor9g(){
	difference(){			
		union(){
			color("Gray") cube([servoX,servoY,servoZ], center=true);
			befestigungZ = 2.7;
            color("Gray") translate([0,0,offsetBefestigungZ+befestigungZ/2])
                cube([32,12,befestigungZ], center=true);
			color("Gray") translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=20, center=true);
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
}

module arm9g(laenge,winkel){
    dicke = 3;
    rAchse = 4;
    rEnde = 2;
    #translate([5.4,0,16])rotate([0,0,winkel]){
        difference(){
            union(){
                translate([0,0,-2]) cylinder(r=rAchse, h=dicke+2);
                linear_extrude(height = dicke, convexity = 10)
                    polygon(points=[[0,rAchse],[0,-rAchse],[laenge,rEnde],[laenge,-rEnde]]
                        , paths=[[0,1,3,2]]);
                translate([laenge,0,0]) cylinder(r=rEnde, h=dicke);
            }
            // die Achse
            translate([0,0,-2.1]) cylinder(r=drehachseR, h=2);
            // das Loch zur Befestigung der Hebelstange
            translate([laenge,0,-.1]) cylinder(d=1.5, h=dicke+.2);
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

motor9g();
arm9g(laenge=20,winkel=90);
holder9g();
