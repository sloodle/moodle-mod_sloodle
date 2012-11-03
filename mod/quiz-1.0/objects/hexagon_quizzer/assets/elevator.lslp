vector RED =<1.00000, 0.00000, 0.00000>;
vector ORANGE=<1.00000, 0.43763, 0.02414>;
vector YELLOW=<1.00000, 1.00000, 0.00000>;
vector GREEN=<0.00000, 1.00000, 0.00000>;
vector BLUE=<0.00000, 0.00000, 1.00000>;
vector BABYBLUE=<0.00000, 1.00000, 1.00000>; 
vector PINK=<1.00000, 0.00000, 1.00000>;
vector PURPLE=<0.57338, 0.25486, 1.00000>;
vector BLACK= <0.00000, 0.00000, 0.00000>;
vector WHITE= <1.00000, 1.00000, 1.00000>;
vector myColor;
rotation myRot;
default {
	on_rez(integer start_param) {
		if (start_param==1){
			myColor=YELLOW;
			myRot = <0.000000,0.000000,0.390731,0.920505>;			
		}else
		if (start_param==2){
			myColor=PINK;
			myRot = <0.000000,0.000000,0.000000,1.000000>;
		}else
		if (start_param==3){
			myColor=BABYBLUE;
			myRot = <0.000000,0.000000,-0.529972,0.848015>;
		}else
		if (start_param==4){
			myColor=RED;
			myRot = <0.000000,0.000000,-0.883021,0.469334>;
		}else
		if (start_param==5){
			myColor=BLUE;
			myRot = <0.000000,0.000000,0.998622,0.052473>;
		}else
		if (start_param==6){
			myColor=GREEN;
			myRot = <0.000000,0.000000,0.833830,0.552022>;
		}else
		
		////
		if (start_param==-1){
			myColor=YELLOW;
			myRot = <0.000000,0.000000,-0.883021,0.469334>;						
		}else
		if (start_param==-2){
			myColor=PINK;
			myRot = <0.000000,0.000000,0.998622,0.052473>;
		}else
		if (start_param==-3){
			myColor=BABYBLUE;
			myRot = <0.000000,0.000000,0.833830,0.552022>;
		}else
		if (start_param==-4){
			myColor=RED;
			myRot = <0.000000,0.000000,0.390731,0.920505>;
		}else
		if (start_param==-5){
			myColor=BLUE;
			myRot = <0.000000,0.000000,0.000000,1.000000>;
		}else
		if (start_param==-6){
			myColor=GREEN;
			myRot = <0.000000,0.000000,-0.529972,0.848015>;
			
		}
		llSetColor(myColor, ALL_SIDES);
		llSetRot(myRot);
		
	}
    
}
