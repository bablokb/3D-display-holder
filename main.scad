// ---------------------------------------------------------------------------
// 3D-Model (OpenSCAD): final model
//
// Author: Bernhard Bablok
// License: GPL3
//
// https://github.com/bablokb/3D-display-holder
// ---------------------------------------------------------------------------

include <BOSL2/std.scad>
include <pcb_holder.scad>

TEST = false;

x_pcb = 59.3;
xs_pcb = 2.54;     // offset screw
x_cout = 13.5;
x_border = 5.3+w4;

y_pcb = 35.5;
ys_pcb = xs_pcb;
y_cout = 16.0;
y_border = x_border;

z_pcb  = 1.7;     // it is 1.6, but we need a bit more room
ds_pcb = 2.3;     // diameter screw

//z_sup  = 2;       // this is the default anyway

x_display = pcb_holder_dim(x_pcb);
y_display = pcb_holder_dim(y_pcb);
z_display = pcb_holder_z(z_pcb=z_pcb);
z_border = b;
z_base    = z_display+2*b;

a_stand = 50;     // angle of stand
y_add = tan(90-a_stand) * (z_base+gap/2);

y_plate = y_display * sin(90-a_stand);
d_plate = 2.5 + 2*gap;

// --- display-extension   ---------------------------------------------------

module extension(x,z) {
  color("blue") ymove(-y_display/2-y_add/2)
         cuboid([x,y_add,z],anchor=BOTTOM+CENTER);
}

// --- cutout EYESPI-cable   -------------------------------------------------

module cutout_eyespi(z) {
  zmove(-fuzz) ymove(-y_pcb/2) 
    cuboid([x_cout,3*y_add,z+2*fuzz],anchor=BOTTOM+CENTER);
}

// --- display-holder   ------------------------------------------------------

module display() {
  difference() {
    union() {
      pcb_holder(x_pcb=x_pcb, y_pcb=y_pcb, z_pcb=z_pcb,
                 x_screw = xs_pcb, y_screw = ys_pcb,
                 d_screw = ds_pcb, screws = [1,0,0,0]);
      extension(x_display,z_display);
    }
    // cutouts
    cutout_eyespi(z_display+z_border);
    zmove(-fuzz) xmove(-x_pcb/2)
        cuboid([5*w4,y_cout,z_display+2*fuzz],anchor=BOTTOM+CENTER);
  }
}

// --- base (stand)   --------------------------------------------------------

module base() {
  x = x_display + 2*w2;
  z = z_base + gap/2;
  difference() {
    union() {
      // bottom-side
      cuboid([x+2*w2,y_display,b],anchor=BOTTOM+CENTER);
      // top-side
      color("green") zmove(z-b) ymove(-y_display/2+y_border/2)
             cuboid([x,y_border,b],anchor=BOTTOM+CENTER);
      // front-side
        extension(x,z);
    }
    cutout_eyespi(z);
  }
  // sides
  move([-x/2-w2/2,-y_display/2-(y_add/2-y_border),0])
   cuboid([w2,y_add+2*y_border,z],anchor=BOTTOM+CENTER);
  move([+x/2+w2/2,-y_display/2-(y_add/2-y_border),0])
   cuboid([w2,y_add+2*y_border,z],anchor=BOTTOM+CENTER);
  // cover
  move([-x/2-w2+x_border/2,-y_display/2+1.5*y_border,z-b])
   color("pink") cuboid([x_border,y_border,b],anchor=BOTTOM+CENTER);
  move([+x/2+w2-x_border/2,-y_display/2+1.5*y_border,z-b])
   color("pink") cuboid([x_border,y_border,b],anchor=BOTTOM+CENTER);
  
}

// --- bottom plate   --------------------------------------------------------

module plate() {
  difference() {
    x = x_display + 4*w2;
    cuboid([x,y_plate,b],
            rounding=3, edges=[BACK+RIGHT,BACK+LEFT],anchor=BOTTOM+CENTER);
    move([x/2-d_plate,y_plate/2-d_plate,-fuzz])
       cyl(d=d_plate,h=b+2*fuzz, anchor=BOTTOM+CENTER);
    move([-x/2+d_plate,y_plate/2-d_plate,-fuzz])
       cyl(d=d_plate,h=b+2*fuzz, anchor=BOTTOM+CENTER);
  }
}

// --- final object   --------------------------------------------------------

module main() {
  difference() {
    union() {
      ymove(y_plate/2-fuzz) plate();
      // move and tilt the display
      xrot(a_stand)
        ymove(y_display/2)
          base();
    }
    cuboid([100,100,100],anchor=TOP+CENTER);
  }
}

//display();
//base();
//plate();
main();