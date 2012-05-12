//
// The line above should be left blank to avoid script errors in OpenSim.

/*
*  Part of the Sloodle project (www.sloodle.org)
*
*  Copyright (c) 2011-06 contributors (see below)
*  Released under the GNU GPL v3
*  -------------------------------------------
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  All scripts must maintain this copyrite information, including the contributer information listed
*  
* Contributers:
*  Originally Written by Tdub Dowler
*  Modified by Awsoonn Rawley
*  Refactored by Strife Onizuka
*  Modified by Paul Preibisch and Edmund Edgar for Sloodle and Opensim to eliminate the need for a sepearate script in each zztext prim, and to be independant of texture UUIDS
*  
*/ 
list decode=[]; // to handle special characters from CP850 page for european countries
integer SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE = 1639271140;
integer SLOODLE_CHANNEL_SCOREBOARD_SCORES = 1639272100;
integer SLOODLE_CHANNEL_SCOREBOARD_SCORES_CONFIG = -1639272000;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_CELL_INFO=-1639272001; //this is set on the zztext prims cell description
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_REMAP_INDICIES=-1639272002;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_RESET_INDICIES=-1639272003;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_THICKNESS=-1639272004;
integer  SLOODLE_CHANNEL_SCOREBOARD_SCORES_SET_COLOR=-1639272005;

integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_CONFIG = -1639273000;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_CELL_INFO = -1639273001;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_REMAP_INDICIES = -1639273002;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_RESET_INDICIES = -1639273003;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_THICKNESS = -1639273004;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM_SET_COLOR = -1639273005;
integer SLOODLE_CHANNEL_SCOREBOARD_TEAM = 1639273100;

integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_CONFIG = -1639274000;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_CELL_INFO  = -1639274001;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_REMAP_INDICIES  = -1639274002;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_RESET_INDICIES = -1639274003;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_THICKNESS  = -1639274004;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY_SET_COLOR = -1639274005;
integer SLOODLE_CHANNEL_SCOREBOARD_CURRENCY = 1639274100;

integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_CONFIG = -1639275000;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_CELL_INFO = -1639275001;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_REMAP_INDICIES = -1639275002;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_RESET_INDICIES = -1639275003;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_THICKNESS = -1639275004;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE_SET_COLOR = -1639275005;
integer SLOODLE_CHANNEL_SCOREBOARD_TITLE= 1639275100;
integer SLOODLE_CHANNEL_ZZTEXT_TEXTURE_CONFIG= -1639276000;

list CHARACTER_GRID;
integer FACE_1          = 3;
integer FACE_2          = 7;
integer FACE_3          = 4;
integer FACE_4          = 6;
integer FACE_5          = 1;
/*
   FUNCTION debug(string message) 
     debugging function - use the prim material setting as a toggle for debug messages.
     if material is flesh (means a human needs to read message) then debugging is on, of material is not flesh
     debugging is off
*/
debug (string message){
      list params = llGetPrimitiveParams ([PRIM_MATERIAL ]);
      if (llList2Integer (params ,0)==PRIM_MATERIAL_FLESH){
           llOwnerSay(llGetObjectName()+"."+llGetScriptName()+": "+message);
     }
} 

 vector GetGridOffset(vector grid_pos) {
    // Zoom in on the texture showing our character pair.
    integer Col = llRound(grid_pos.x) % 40; // PK was 20
    integer Row = llRound(grid_pos.y) % 20; // PK was 10
    // Return the offset in the texture.
    return <-0.45 + 0.025 * Col, 0.45 - 0.05 * Row, 0.0>; // PK was 0.05 and 0.1
}
/*
* renderString will render the string to all the zzTextprims having the name which is set via the zzTextPrimNames
* make sure to name each zztextprim the same name, and also in their description field to number each prim from 1 - your max number of zztextprims,
*  So if your display has 50 prims, put in their description 1, then the next zzprim description 2 etc
*/
renderString(string str,string zzTextPrimNames){
                integer prims = llGetNumberOfPrims();
                vector GridPos1;vector GridPos2;vector GridPos3;vector GridPos4;vector GridPos5;  
                integer currentLink=0;
                integer currentCellCharPosition=0;
                string linkDescription;
                string textToRender;
               do{
                       if (llList2String(llGetLinkPrimitiveParams(currentLink, [PRIM_NAME]),0)==zzTextPrimNames){
                                 currentCellCharPosition=llList2Integer(llGetLinkPrimitiveParams(currentLink, [PRIM_DESC]),0)*10;
                                //get the part of the text between the cells start and end position
                                textToRender = llGetSubString(str, currentCellCharPosition, currentCellCharPosition+ 9);
                                   // Get the grid positions for each pair of characters.
                                GridPos1 = GetGridPos( GetIndex(llGetSubString(textToRender, 0, 0)),GetIndex(llGetSubString(textToRender, 1, 1)) );
                                GridPos2 = GetGridPos( GetIndex(llGetSubString(textToRender, 2, 2)),GetIndex(llGetSubString(textToRender, 3, 3)) );
                                GridPos3 = GetGridPos( GetIndex(llGetSubString(textToRender, 4, 4)),GetIndex(llGetSubString(textToRender, 5, 5)) );
                                GridPos4 = GetGridPos( GetIndex(llGetSubString(textToRender, 6, 6)),GetIndex(llGetSubString(textToRender, 7, 7)) );
                                GridPos5 = GetGridPos( GetIndex(llGetSubString(textToRender, 8, 8)),GetIndex(llGetSubString(textToRender, 9, 9)) );
                                key gridTexture1=  GetGridTexture(GridPos1);key gridTexture2=  GetGridTexture(GridPos2);key gridTexture3=  GetGridTexture(GridPos3);key gridTexture4=  GetGridTexture(GridPos4);key gridTexture5=  GetGridTexture(GridPos5);
                                llSetLinkPrimitiveParamsFast(currentLink, 
                                        [
                                            PRIM_TEXTURE, FACE_1, gridTexture1, <0.125, 0.05, 0>, GetGridOffset(GridPos1) + <0.0375-0.025-0.002, 0.025, 0>, 0.0,
                                            PRIM_TEXTURE, FACE_2, gridTexture2, <0.05, 0.05, 0>, GetGridOffset(GridPos2)+<-0.025-0.002, 0.025,0>, 0.0,
                                            PRIM_TEXTURE, FACE_3, gridTexture3, <-0.74, 0.05, 0>, GetGridOffset(GridPos3)+ <-.34-0.002, 0.025, 0>, 0.0,
                                            PRIM_TEXTURE, FACE_4,gridTexture4, <0.05, 0.05, 0>, GetGridOffset(GridPos4)+<-0.025-0.002, 0.025,0>, 0.0,
                                            PRIM_TEXTURE, FACE_5, gridTexture5, <0.125, 0.05, 0>, GetGridOffset(GridPos5) + <0.0375-0.025-0.077-0.002, 0.025, 0>, 0.0
                                        ]
                                );
                      }
            }while(++currentLink < prims); 
}
loadTextures(){
    CHARACTER_GRID=[];
    integer numTextures;
    numTextures = llGetInventoryNumber(INVENTORY_TEXTURE);
    integer i=0;
        for (i=0;i<numTextures;i++){
            string name = llGetInventoryName(INVENTORY_TEXTURE,i);
            CHARACTER_GRID+=llGetInventoryKey(name);
    }
}


string GetGridTexture(vector grid_pos) {
    // Calculate the texture in the grid to use.
    integer GridCol = llRound(grid_pos.x) / 40; // PK was 20
    integer GridRow = llRound(grid_pos.y) / 20; // PK was 10
 
    // Lookup the texture.
    key Texture = llList2Key(CHARACTER_GRID, GridRow * (GridRow + 1) / 2 + GridCol);
    return Texture;
}

string  LOAD_MSG            = "Loading...";
///////////// END CONSTANTS ////////////////
integer prims;
set_scoreboard_score_text(string msg)
{
    renderString(msg,"zztextprim");
}
set_scoreboard_team_text(string msg)
{
    renderString(msg,"zztextprim_team");
}
set_scoreboard_currency_text(string msg)
{
    renderString(msg,"zztextprim_currency");
}
set_scoreboard_title_text(string msg)
{
    renderString(msg,"zztextprim_title");
}

vector GetGridPos(integer index1, integer index2) {
    // There are two ways to use the lookup table...
    integer Col;
    integer Row;
    if (index1 >= index2) {
        // In this case, the row is the index of the first character:
        Row = index1;
        // And the col is the index of the second character (x2)
        Col = index2 * 2;
    }
    else { // Index1 < Index2
        // In this case, the row is the index of the second character:
        Row = index2;
        // And the col is the index of the first character, x2, offset by 1.
        Col = index1 * 2 + 1;
    }
    return <Col, Row, 0>;
}
// All displayable characters.  Default to ASCII order.
string gCharIndex;

ResetCharIndex() {
    gCharIndex  = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`";
    // \" <-- Fixes LSL syntax highlighting bug.
    gCharIndex += "abcdefghijklmnopqrstuvwxyz{|}~";
    //        cap cedille      u:         e/            a^         a:          a/         a ring      cedille     e^           e:
    decode=  ["%C3%87", "%C3%BC", "%C3%A9", "%C3%A2", "%C3%A4", "%C3%A0", "%C3%A5", "%C3%A7", "%C3%AA", "%C3%AB",
 
 
        //                    e\           i:               i^            i\                A:          A ring          E/              ae           AE           marker >
        "%C3%A8", "%C3%AF", "%C3%AE", "%C3%AC", "%C3%84", "%C3%85", "%C3%89", "%C3%A6", "%C3%86", "%E2%96%B6" ,
 
        //                 o:               o/           u^          u\              y:               O:             U:          cent           pound        yen
        "%C3%B6", "%C3%B2", "%C3%BB", "%C3%B9", "%C3%BF", "%C3%96", "%C3%9C", "%C2%A2", "%C2%A3", "%C2%A5",
 
        //                 A^              a/              i/                o/            u/              n~           E:            y/              inv ?         O^
        "%C3%82", "%C3%A1", "%C3%AD", "%C3%B3", "%C3%BA", "%C3%B1", "%C3%8B", "%C3%BD", "%C2%BF", "%C3%94",
 
        //                   inv !             I\             I/           degree       E^              I^            o^            U^
        "%C2%A1", "%C3%8C", "%C3%8D", "%C2%B0", "%C3%8A", "%C3%8E", "%C3%B4", "%C3%9B",
 
        //                     Y:          euro           german ss         E\              A\           A/              U\           U/               O\           O/
        "%C3%9D", "%E2%82%AC", "%C3%9F", "%C3%88", "%C3%80", "%C3%81", "%C3%99", "%C3%9A", "%C3%92", "%C3%93",
 
        //                   Sv           sv             zv             Zv              Y:             I:
        "%C5%A0", "%C5%A1", "%C5%BE", "%C5%BD", "%C3%9D", "%C3%8C" ];
 
 
}
integer GetIndex(string char)
{
    integer  ret=llSubStringIndex(gCharIndex, char);
    if(ret>=0) return ret;
 
    // special char do nice trick :)
    string escaped=llEscapeURL(char);
 
    if(escaped=="%E2%80%99") return 7; // remap ’
    //llSay(0,"Looking for "+escaped);
    integer found=llListFindList(decode, [escaped]);
 
    // not found
    if(found<0) return 0;
 
    // return correct index
    return llStringLength(gCharIndex)+found;
 
}
 
XytstOrder()
{ 
    // Fills each cell of the board with it's number.
    string  str = "";
    integer i = 0;
    do
    {
        str += llGetSubString("          " + (string)i,-10,-1);
        llSetText("Generating Pattern: " + (string)i, <0,1,0>, 1.0);
    }while(++i < prims);
 
    llSetText("Displaying Order Test...", <0,1,0>, 1.0);
 
    // Send the message
    llMessageLinked(LINK_SET, SLOODLE_CHANNEL_SCOREBOARD_SCORES_CONFIG, str, "");
 
    llSetText("", <0,1,0>, 0);
}
 
 
default
{
    on_rez(integer start)
    {
        llResetScript();
    }
 
    state_entry()
    {
        // Determin the number of prims.
        prims = llGetNumberOfPrims();
        ResetCharIndex();
         loadTextures();
        // Clear the screen.
         set_scoreboard_score_text("");     
        set_scoreboard_score_text("");
        set_scoreboard_team_text("");
        set_scoreboard_currency_text("");
        set_scoreboard_title_text(LOAD_MSG);    
 
        integer StartLink = llGetLinkNumber() + 1;
        // Configure the board.
        integer i = 0;
       // set_scoreboard_score_text("THIS IS A TEST 123");
      
    } 

    link_message(integer sender_num, integer num, string str, key id) {
        if (num==SLOODLE_CHANNEL_SCOREBOARD_UPDATE_COMPLETE){
            list lines = llParseString2List(str, ["\n"], []);
            list status = llParseString2List(llList2String(lines,1), ["|"], []); //status|page_num|num_page|scoreboard_name|team|currency
            integer pageNum = llList2Integer(status,1);
            integer numPages =  llList2Integer(status,2);
            string scoreboardName=  llList2String(status,3);
            string teamName=  llList2String(status,4);
            string currency=  llList2String(status,5);
            list users;
            integer numLines = llGetListLength(lines);
            debug("****************numLines: "+(string)numLines);
            integer numUsers= llGetListLength(lines)-2;
            integer i=0;
            list scores;
            string scoreboardText="";
            //the first two lines are our status and info lines
            //the remaining lines is our userdata
            for (i=2;i<numLines;i++){
                 list userData=llParseString2List(llList2String(lines,i),["|"], []);
                 debug("parsing: "+llList2String(lines,i));
                 users+=llList2Key(userData,0);
                 scores+=llList2Integer(userData,1);
                 scoreboardText+=llList2String(userData,2);
                 
             }
             
                set_scoreboard_score_text(scoreboardText);
                set_scoreboard_team_text(teamName);
                set_scoreboard_currency_text(currency);          
                set_scoreboard_title_text(scoreboardName);
            }
    }
}


// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/scoreboard-1.0/object_scripts/zztext/_zztext_efficient_board_control.lsl
