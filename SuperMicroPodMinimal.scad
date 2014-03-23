// Author: Peter Withers
// Initial date: 2014-03-16 18:36

chordRatio = 0.16;
fuseRatio = 0.68;
leadingEdgeRadio = 0.12;
vTailRatio = 0.16;
hTailRatio = 0.26;
rudderChordRatio = 0.05; // todo: check this value 
elevatorChordRatio = 0.065; // todo: check this value

carbonfiberLength = 1000;
span = carbonfiberLength / (1 + fuseRatio - rudderChordRatio);
dihedral = 10;
sweep = 20;
rudderChord = span * rudderChordRatio;
elevatorChord = span * elevatorChordRatio;
boomLength = span * fuseRatio - rudderChord; // todo: this must subtract the rudder length
wingLength = span / 2;
rootChord = span * chordRatio;
leadingEdgeOffset = span * leadingEdgeRadio;
tailWidth = span * hTailRatio;
tailHeight = span * vTailRatio;

echo("span", span);
echo("dihedral", dihedral);
echo("sweep", sweep);
echo("root chord", rootChord);
echo("boom length", boomLength);
echo("total length", rudderChord + boomLength);
echo("leading edge from tip", leadingEdgeOffset);
echo("tail width", tailWidth);
echo("tail height", tailHeight);
echo("rudder chord", rudderChord);
echo("elevator chord", elevatorChord);

echo("boom plus span (which should be the carbon fibre lenght)", boomLength+span);

wallThickness = 1.4;
totalHeight = 19;
motorHoleCount = 3;
motorHoleOffsetRadius = 8.0;// todo: this might be too small, maybe .5 more is good
motorHoleDiameter = 1.5;
motorHoleDepth = 17;
//motorZpos = 5; // correct this value
boardWidth = 25 + 4;
boardLength = 33 + 2;
cowlingTipRadius = 9;
cowlingTailRadius = boardWidth*0.65;
cowlingLength = 30;
carbonfiberDiameter = 2.5; // todo: consider making this thicker


module makeMainShape(shrinkValue){
	translate([shrinkValue/2,0,shrinkValue])
	cube([boardLength-shrinkValue,boardWidth-shrinkValue*2,totalHeight],true);
	rotate([0,90,0])translate([0,0,(boardLength+cowlingLength)/2-1-shrinkValue])
	intersection(){
		cylinder(cowlingLength+1, cowlingTailRadius-shrinkValue, cowlingTipRadius-shrinkValue,true);
		translate([-shrinkValue,0,0]) cube([totalHeight,boardWidth-shrinkValue*2,cowlingLength-shrinkValue*2],true);
	}
}

module makeMountHoles(){
	// antenna hole
	translate([-boardLength,-boardWidth*0.24,-totalHeight/2+wallThickness])
	cube([boardLength,2,2]);
	// battery cable hole
	// todo: make this angled so that the wire comes out at the correct location on the board while maintining the current motor entry point
	// todo: make this curved so that the wire does not get bent at an angle 
	// todo: make sure this channel does not interfere with the boom hole
	translate([boardLength/2,-boardWidth*0.25,totalHeight*0.15-totalHeight*0.5])
		rotate(18,[0,0,1]){ 
			difference(){
				cube([boardLength,2,totalHeight*1]);
				translate([cowlingLength/1.6,1,-totalHeight*0.2])rotate(90,[1,0,0]) cylinder(5,cowlingLength/1.8,cowlingLength/1.8,true);
			}
		}
	// motor cable hole
	translate([boardLength/2-8,-boardWidth,-totalHeight/2+wallThickness])
	cube([8,boardWidth,5]);
	// motor holes
	translate([cowlingLength+boardLength/2,0,0]) rotate([0,90,0]){
		cylinder(h = 10, r=motorHoleDiameter, center = true);
		for (holeIndex = [0 : motorHoleCount]){
			rotate(holeIndex * 360 / motorHoleCount, [0, 0, 1])
			translate([motorHoleOffsetRadius,0,-motorHoleDepth/2])
			cylinder(h = motorHoleDepth, r=motorHoleDiameter/2, center = true);
		}
	}
}
module makeCarbonFiberRodMountHoles(){
	translate([(boardLength+cowlingLength)/1.8,0,0]){
		rotate(270,[0,1,0])cylinder(boomLength, carbonfiberDiameter/2, false);
		for (wingIndex = [90-dihedral,dihedral-90]){
			rotate(90,[0,0,1])rotate([-sweep,wingIndex,0])
				translate([0,0,carbonfiberDiameter/2])
					cylinder(wingLength, carbonfiberDiameter/2, false);
		}
	}
//cylinder(h = 10, r=motorHoleDiameter, center = true);
//carbonfiberDiameter
//boomLength
//wingLength
//dihedral
// sweep
}

module makeHousing(){
	intersection(){
		union(){
			translate([0,0,-totalHeight]) rotate([0,-15,0])
				cube([(boardLength+cowlingLength)*2,boardWidth*2,totalHeight*2],true);
			translate([wallThickness/2-boardLength/2,0,-totalHeight*0.5+carbonfiberDiameter])
				// todo: this is not strong enough to print
				cube([wallThickness,carbonfiberDiameter*2,totalHeight],true);
		}
		difference(){
			makeMainShape(0);
			union(){
				difference(){
					makeMainShape(wallThickness);
					translate([boardLength,0,0])
						cube([cowlingLength,boardWidth+2,totalHeight+2],true);
				}
				makeMountHoles();
makeCarbonFiberRodMountHoles();			
			}
		}
	}
}
makeHousing();
%makeCarbonFiberRodMountHoles();
