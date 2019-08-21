// OpenSCAD model of pcb2molex8878 carrier
// for pcb2molex8878.kicad_pcb

// Carrier to hold a pcb in place of a DIP28 chip
// in the Molex 8878 socket found in some vintage computers.
// Ex: Tandy Model 100, 102, 200, 600
//     Epson PX-4, PX-8

// Brian K. White - b.kenyon.w@gmail.com
// http://tandy.wiki/pcb2molex8878
// https://github.com/aljex/pcb2molex8878/

// -------------------------------------------------------------------------
// UNITS: mm

// Which version of the carrier to produce:
// "original" - fits REX_bkw_c8 and original Teeprom
// "pin" - fits REX_bkw_c9
// "chamfer" - fits REX_bkw_c10 and current Teeprom
// "no_polarity" - fits original REX1 & FigTroniX with ends sanded down
variant = "chamfer";

// main outside box
main_x = 39.8;    // 050395288_sd.pdf DIM. F
main_y = 16.7;
main_z = 7.48;

// cut-away clearance around socket contacts
// so that empty carrier can not get trapped
contacts_x = 34.8;
contacts_y = 2.6; // cuts inwards from main_y

// pcb
pcb_x = (variant=="original") ? 37.5 : main_x-1.6;     // leave walls > 0.7  ( (main_x-pcb_x)/2 >= 0.7 )
pcb_y = (variant=="original") ? 15.3 : 16.3;
pcb_z = 1.8;      // thickness of pcb (nominal 1.6, plus 0.2)
pcb_elev = 2.0;   // bottom of pcb above socket floor

// cavity in bottom tray for backside components and through-hole legs 
pocket_x = 36;
pocket_y = 12.5;  // allow tsop48, leave walls >= 0.7
pocket_z = 1.2;   // allow tsop48, leave floor >= 0.7

// wedge corner posts - pins 1/28 end
cpwedge_xwide = 1.6;      // thick end of wedge
cpwedge_xnarrow = 1.1;    // thin end of wedge
cpwedge_y = 21.2;         // total Y outside end to end both posts

// box corner posts - pins 14/15 end
cpbox_x = 2.1;    // X len of 1 post
cpbox_y = 1.8;    // Y width of 1 post
cpbox_xe = 0.3;   // X extends past main_x
cpbox_yo = 19.8;  // total Y outside end to end both posts

// socket polarity blades
blade_z = 5.2;            // height from top of main_z to bottom of blade
blade_xwide = 2.5;        // wide part extend past main_x
blade_xnarrow = 1.4;      // narrow part extend past main_x
blade_thickness = 1.4;

// finger pull wings
wing_y = 8.95;
wing_x = 3.2;             // extend past main_x
wing_thickness = 1.2;

// pcb retainer wedges
ret_x = 1;        // thick end
ret_y = 10;       // length
ret_z = 2;        // height

// label text
text_z = 0.1;             // depth into surface
text_v = "pcb2molex8878"; // value

// pcb polarity pin (used if pcb_ptype=1)
pin_x = 14.53;                    // center X
pin_y = 3.4;                      // center Y
pin_z = pcb_elev+pcb_z-0.2;       // top of pin, 0.2 below top of pcb
pin_d = (variant=="original") ? 2.6 : 2;       // diameter, 0.2 less than hole in pcb

// pcb polarity chamfer (used if pcb_ptype=2)
pcb_polarity_chamfer = 1.6;   // pin 1 corner polarity chamfer

o = 0.1;  // overcut - extend cut shapes beyond the outside surfaces they cut from, prevent zero-thickness planes in previews, renders, & mesh outputs
corner_wall_chamfer = 0.5; // size of chamfers on inside side walls - acommodate mill radius in pcb edge cuts
extra_trap = (variant=="chamfer"||variant=="no_polarity") ? 0.2 : 0; // leave this much of the side walls on the pin1 & pin28 corner posts, even though the wall is too thin, to provide a little more secure side-side trapping of the pcb on that end, when there is no pin to do it

// ===============================================================

pocket_floor = pcb_elev-pocket_z;

module mirror_copy(vector){
  children();
  mirror(vector) children();
}

// socket polarity blade
module blade(){
  rotate([90,0,0])
    translate([0,-blade_z+main_z/2,0])
      linear_extrude(blade_thickness)
        polygon([
          [0,0],
          [0,blade_z],
          [blade_xwide,blade_z],
          [blade_xwide,blade_z-wing_thickness],
          [blade_xnarrow,blade_z-wing_thickness*2],
          [blade_xnarrow,0]
        ]);
}

// most of the body
difference(){

  // === ADD Shapes ===
  union(){

    // main outer box
    cube([main_x,main_y,main_z],center=true);

    // wedge-shaped corner posts at pin1 & pin28
    mirror_copy([0,1,0]) // pin 1
      translate([-main_x/2,main_y/2,-main_z/2]) // pin 28
        linear_extrude(main_z)
          polygon([
            [0,0],
            [0,cpwedge_y/2-main_y/2],
            [cpwedge_xnarrow,cpwedge_y/2-main_y/2],
            [cpwedge_xwide,0]
          ]);
    
    // box-shaped corner posts at pin14 & pin15
    mirror_copy([0,1,0]) // pin 14
      translate([main_x/2-cpbox_x+cpbox_xe,cpbox_yo/2-cpbox_y,-main_z/2]) // pin 15
        cube([cpbox_x,cpbox_y,main_z]);
    
    // finger pull wings
    mirror_copy([1,0,0]) // wing 1 / pin 1/28 end
      translate([main_x/2+wing_x/2,0,main_z/2-wing_thickness/2]) // wing 2 / pin 14/15 end
        cube([wing_x,wing_y,wing_thickness],center=true);

    // socket polarity blades
    translate([-main_x/2,-blade_thickness/2,0]) // pin 1/28 end
      rotate([0,0,180])
        blade();
    mirror_copy([0,1,0]) // pin 14
      translate([main_x/2,wing_y/2,0]) // pin 15
          blade();
  }

  // === SUBTRACT Shapes ===
  union(){
    // main cavity for pcb
    translate([0,0,pcb_elev])
      cube([pcb_x,pcb_y,main_z],center=true);

    if(variant=="original"){
      // chamfer inside edge of original style thick side walls 
      c = corner_wall_chamfer+o*2;
      mirror_copy([1,0,0]) // pins 1 & 28
        mirror_copy([0,1,0]) // pin 14
          translate([contacts_x/2-o,pcb_y/2-o,-main_z/2+pcb_elev]) // pin 15
            linear_extrude(main_z-pcb_elev+o)
              polygon([
                [0,0],
                [c,0],
                [0,c]
              ]);
    } else {
      // remove side walls for all other styles
      c = main_x/2-cpwedge_xwide-contacts_x/2+o; // square large enough to cut the vertical walls from the corner posts
      ce = (variant=="chamfer") ? pcb_z : 0; // offset elev for pin1 wall cut
      translate([-main_x/2+cpwedge_xwide+extra_trap,-pcb_y/2-c/2,-main_z/2+pcb_elev+ce]) cube([c,c,main_z-pcb_elev+o]); // pin 1 wedge post
      translate([-main_x/2+cpwedge_xwide+extra_trap,pcb_y/2-c/2,-main_z/2+pcb_elev]) cube([c,c,main_z-pcb_elev+o]); // pin 28 wedge post
      mirror_copy ([0,1,0]) // pin 14 box corner post
        translate([main_x/2+cpbox_xe-cpbox_x-c,pcb_y/2-c/2,-main_z/2+pcb_elev]) // pin 15 box corner post
          cube([c,c,main_z-pcb_elev+o]);
    }
    
    // pocket for backside components
    translate([0,0,pcb_elev-pocket_z])
      cube([pocket_x,pocket_y,main_z],center=true);
    
    // clearance for socket contacts
    mirror_copy([0,1,0])
      translate([0,-main_y/2,0])
        cube([contacts_x,contacts_y,main_z+o*2],center=true);
    
    // notch in wing 1 / pin 1/28 end
    translate([-main_x/2-wing_x-o,-blade_thickness/2,main_z/2-blade_thickness+o])
      cube([wing_x-blade_xwide+o,blade_thickness,wing_thickness+o*2]);

    // engrave label into floor
    translate([0,0,-main_z/2+pocket_floor-text_z])
      linear_extrude(text_z+o)
        text(text_v,size=3,halign="center");

  }
}

// pcb retainer snap wedges
mirror_copy([1,0,0]) // pin 14/15 end
  translate([-pcb_x/2,ret_y/2,-main_z/2+pcb_elev+pcb_z]) // pin 1/28 end
    rotate([90,0,0])
      linear_extrude(ret_y)
        polygon([
          [0,0],
          [0,ret_z],
          [ret_x,0]
        ]);

// pcb polarity
if(variant=="chamfer")
  translate([-pcb_x/2,-pcb_y/2,-main_z/2+pcb_elev])
    linear_extrude(pcb_z)
      polygon([
        [0,0],
        [0,pcb_polarity_chamfer],
        [pcb_polarity_chamfer,0]
      ]);
else if(variant!="no_polarity")
  translate([-pin_x,-pin_y,-main_z/2+pocket_floor]){
    cylinder(h=pin_z-pocket_floor,d=pin_d,$fn=18); // pin
    cylinder(h=0.2,d1=pin_d+2,d2=pin_d,$fn=18); // fillet
  }