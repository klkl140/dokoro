//Platzhalter für Kugellager

module kugellager625(){ //5*16*5
    difference(){
        cylinder(d=16,h=5,center=true);
        translate([0,0,-.1]) cylinder(d=5,h=5.3,center=true);
    }
}

kugellager625();
