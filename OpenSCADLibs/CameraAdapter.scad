use <ISOThreadCust.scad>

// base was https://github.com/luisibanez/ShapesFor3DPrinting/blob/master/OpenSCAD/piCameraMicroscopeAdapter.scad

// piCameraAdapter() ist eine Hülle für eine piCamera, 0 im Punkt der Kamera
// piCameraBackCover(-.2) der dazugehörige Schiebedeckel (mit clearance)
// threadAdapter();			// Adapter mit Gewinde
// kogetoAdapter();

banana=0;	// 0 fuer raspberry
gehaeuseAussen = 35 + banana*20;    // war 40
cameraAussenX = 25  + banana*15;
cameraAussenY = 24  + banana*16;
gehaeuseZ = 10;

snapSize = 3;					// die Seitenlaenge der quadratischen Verbindungen
snapHeight = 2;				    // die Hoehe
// ein quadratischer Anschlusspunkt für andere Teile
module snap(position,clearance) {
    c = clearance;
    translate(position) cube(size=[snapSize+c,snapSize+c,snapHeight],center=true);
}

module snaps(clearance,z) {
    r = 16;				// der Radius für die Positionen der 4 quadratischen Anschlusspunkte
    union() {
        snap([ r, 0,z-.1],clearance);
        snap([ 0, r,z-.1],clearance);
        snap([-r, 0,z-.1],clearance);
        snap([ 0,-r,z-.1],clearance);
    }
}

module cylindricAdapter(inRadius,exRadius,height) {
    union() {
        //translate([0,0,5])
            difference() {
                cylinder(r=exRadius, h=height, center=true);		//aussen
                cylinder(r=inRadius, h=height+.1, center=true);	//innen
            }
            snaps(clearance=-0.2,z=height/2+snapHeight/2);
    }
}

module threadAdapter(){
    dickeAnschluss=2;			// bevor das Gewinde kommt
    gewindeDia = 36.7;
    inDiameter = 28;
    exDiameter = 42;			
    hoehe=10;
    gHoehe = hoehe-dickeAnschluss;
    union(){
        difference(){
            cylindricAdapter(inDiameter/2,exDiameter/2,height=hoehe);
            translate([0,0,-hoehe/2-.1]) cylinder(d=gewindeDia,h=gHoehe,$fn=100);
        }
        translate([0,0,-hoehe/2]) thread_in_pitch(gewindeDia,gHoehe,2);		// das Deckelgewinde
    }
}

module kogetoAdapter()
{
    grundPlatteZ=2.8;		// gemessen 3mm
    cylinderAussen=31.3;
    gewindesteigung=.8;	    // so ganz passt das noch nicht
    gewindehoehe=2.5;
    wandstaerke=6;
    oberkanteZ = -grundPlatteZ/2-gewindehoehe;
    kogetoAussen = 35;	    // Durchmesser am breitesten Punkt

    difference(){
        union(){
            cylindricAdapter((cylinderAussen-wandstaerke)/2,kogetoAussen/2,height=grundPlatteZ);
            //cylinder(d=grundPlatteDia,grundPlatteZ);
            translate([0,0,oberkanteZ]){
                union(){
                    cylinder(d=cylinderAussen-.4, h=gewindehoehe, $fn=100);
                    translate([0,0,0]){
                        thread_out_pitch(cylinderAussen,gewindehoehe,gewindesteigung);
                    }
                }
            }
        }
        translate([0,0,-0.1+oberkanteZ])
            cylinder(d=cylinderAussen-wandstaerke, h=grundPlatteZ+gewindehoehe+.2);
    }
}

module cableOpening() {
    translate([0,14,3])
        cube(size=[17,12,4.1],center=true);
}

module chipOpening() {
    clearance = 0.5;
    c = 2 * clearance;
    translate([0,-9.5,-0.1])
        cube(size=[8+c,10+c,4.1],center=true);
}

module lensOpening() {
    clearance = 0.5;
    c = 2 * clearance;
    translate([0,0,-2.5])
        cube(size=[8+c,8+c,5.1], center=true);
}

module boardOpening() {
    clearance = 0.5;
    c = 2 * clearance;
    translate([0,-3,2.5])
        cube(size=[cameraAussenX+c,cameraAussenY+c,5.1], center=true);
}

module cameraFrame() {
    translate([0,-0.5,0])
        cube(size=[gehaeuseAussen,gehaeuseAussen,gehaeuseZ], center=true);
}

module piCameraAdapter() {
    difference() {
        translate([0,0,gehaeuseZ/2]){
            difference() {
                cameraFrame();
                boardOpening();
                lensOpening();
                cableOpening();
                chipOpening();
            }
        }
        snaps(clearance=0.2,z=snapHeight/2);			//die vier Luecken
        translate([0,0,gehaeuseZ-deckelZ]) piCameraBackCover(0.5);
    }
}

deckelZ=2;
deckelY=24.5;
module piCameraBackCoverBevel(clearance) {
    hw = ( 25 / 2 ) + clearance;
    he = hw + 1.0;
    polyhedron
        (points = [
            [ hw, -deckelY/2, -1 ],
            [ hw,  deckelY/2, -1 ], 
            [ hw,  deckelY/2,  1 ], 
            [ hw, -deckelY/2,  1 ],
            [ he, -deckelY/2, -1 ],
            [ he,  deckelY/2, -1 ] 
            ], 
        faces = [
            [ 0, 1, 4 ],
            [ 1, 5, 4 ],
            [ 0, 4, 3 ],
            [ 1, 2, 5 ],
            [ 2, 3, 4 ],
            [ 2, 4, 5 ],
            [ 0, 2, 1 ],
            [ 0, 3, 2 ]
        ]
    );
}

module piCameraBackCoverBevels(clearance) {
    union() {
        piCameraBackCoverBevel(clearance);
        mirror([1,0,0])
            piCameraBackCoverBevel(clearance);
    }
}

module piCameraBackCover(clearance) {
    c = 2*clearance;
    translate([0,-5.6,deckelZ/2])
        union() {
            piCameraBackCoverBevels(clearance);
            difference() {
                cube(size=[25+c,deckelY,deckelZ],center=true);
                translate([0,9,0])
                    cube(size=[22,7,deckelZ+.1],center=true);
            }
        }
}

//piCameraAdapter();
piCameraBackCover(0.0);
//threadAdapter();			// Adapter mit Gewinde
//kogetoAdapter();
