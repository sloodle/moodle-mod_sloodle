// LSL script generated: xytext_prims.xytext.lslp Sat Mar 20 13:27:17 Pacific Daylight Time 2010
/*********************************************
*  Copyright (c) 2009 Paul Preibisch
*  Released under the GNU GPL 3.0
*  This script can be used in your scripts, but you must include this copyright header as per the GPL Licence
*  For more information about GPL 3.0 - see: http://www.gnu.org/copyleft/gpl.html
* 
*
*  This script is part of the SLOODLE Project see http://sloodle.org
*
*  XyText v1.0.3 Script (5 Face, Multi Texture)
* 
*  Written by Xylor Baysklef
* 
*  Modified by Thraxis Epsilon January 20, 2006
*  Added Support for 5 Face Prim, based on modification
*  of XyText v1.1.1 by Kermitt Quick for Single Texture.
*  See: http://wiki.secondlife.com/wiki/XyText_1.5
*
*  Modified for SLOODLE by Paul Preibisch
* 
*
*  xytext.lsl
*
* The description field of this linked prim should look like:
* cell:0,row:0,display:scoreboard,channel:100100,charPos:10
* cell is the cell number of this prim starting from 0 up to the number of prims you have in your display board
* row is the row of the display board this prim is on (0 is the top row)
* display is the name of the group of display prims this prim belongs too
* channel is the channel this script listens to for text to display
* charpos is the char index this script is responsible for displaying text for
*
* Origionally, charpos and channel were obtained through an init script which sent the channel and index to each linked prim
* This however caused some xyprims not to be properly cleared when the script was reset.
* Hardcoding the charpos in the description field of the prim should fix this problem    
*
*********************************************/

/////////////// CONSTANTS ///////////////////
// XyText Message Map.
integer DISPLAY_STRING = 204000;
integer DISPLAY_EXTENDED = 204001;
integer REMAP_INDICES = 204002;
integer RESET_INDICES = 204003;
integer SET_THICKNESS = 204006;
integer SET_COLOR = 204007;
integer myRow;
integer myCell;
string myType;
// This is an extended character escape sequence.
string ESCAPE_SEQUENCE = "\\e";
 
// This is used to get an index for the extended character.
string EXTENDED_INDEX = "123456789abcdef";
 
// Face numbers.
integer FACE_1 = 3;
integer FACE_2 = 7;
integer FACE_3 = 4;
integer FACE_4 = 6;
integer FACE_5 = 1;
 
// Used to hide the text after a fade-out.
key TRANSPARENT = "701917a8-d614-471f-13dd-5f4644e36e3c";
// This is a list of textures for all 2-character combinations.
list CHARACTER_GRID = ["00e9f9f7-0669-181c-c192-7f8e67678c8d","347a5cb6-0031-7ec0-2fcf-f298eebf3c0e","4e7e689e-37f1-9eca-8596-a958bbd23963","19ea9c21-67ba-8f6f-99db-573b1b877eb1","dde7b412-cda1-652f-6fc2-73f4641f96e1","af6fa3bb-3a6c-9c4f-4bf5-d1c126c830da","a201d3a2-364b-43b6-8686-5881c0f82a94","b674dec8-fead-99e5-c28d-2db8e4c51540","366e05f3-be6b-e5cf-c33b-731dff649caa","75c4925c-0427-dc0c-c71c-e28674ff4d27","dcbe166b-6a97-efb2-fc8e-e5bc6a8b1be6","0dca2feb-fc66-a762-db85-89026a4ecd68","a0fca76f-503a-946b-9336-0a918e886f7a","67fb375d-89a1-5a4f-8c7a-0cd1c066ffc4","300470b2-da34-5470-074c-1b8464ca050c","d1f8e91c-ce2b-d85e-2120-930d3b630946","2a190e44-7b29-dadb-0bff-c31adaf5a170","75d55e71-f6f8-9835-e746-a45f189f30a1","300fac33-2b30-3da3-26bc-e2d70428ec19","0747c776-011a-53ce-13ee-8b5bb9e87c1e","85a855c3-a94f-01ca-33e0-7dde92e727e2","cbc1dab2-2d61-2986-1949-7a5235c954e1","f7aef047-f266-9596-16df-641010edd8e1","4c34ebf7-e5e1-2e1a-579f-e224d9d5e71b","4a69e98c-26a5-ad05-e92e-b5b906ad9ef9","462a9226-2a97-91ac-2d89-57ab33334b78","20b24b3a-8c57-82ee-c6ed-555003f5dbcd","9b481daa-9ea8-a9fa-1ee4-ab9a0d38e217","c231dbdc-c842-15b0-7aa6-6da14745cfdc","c97e3cbb-c9a3-45df-a0ae-955c1f4bf9cf","f1e7d030-ff80-a242-cb69-f6951d4eae3b","ed32d6c4-d733-c0f1-f242-6df1d222220d","88f96a30-dccf-9b20-31ef-da0dfeb23c72","252f2595-58b8-4bcc-6515-fa274d0cfb65","f2838c4f-de80-cced-dff8-195dfdf36b2c","cc2594fe-add2-a3df-cdb3-a61711badf53","e0ce2972-da00-955c-129e-3289b3676776","3e0d336d-321f-ddfa-5c1b-e26131766f6a","d43b1dc4-6b51-76a7-8b90-38865b82bf06","06d16cbb-1868-fd1d-5c93-eae42164a37d","dd5d98cf-273e-3fd0-f030-48be58ee3a0b","0e47c89e-de4a-6233-a2da-cb852aad1b00","fb9c4a55-0e13-495b-25c4-f0b459dc06de","e3ce8def-312c-735b-0e48-018b6799c883","2f713216-4e71-d123-03ed-9c8554710c6b","4a417d8a-1f4f-404b-9783-6672f8527911","ca5e21ec-5b20-5909-4c31-3f90d7316b33","06a4fcc3-e1c4-296d-8817-01f88fbd7367","130ac084-6f3c-95de-b5b6-d25c80703474","59d540a0-ae9d-3606-5ae0-4f2842b64cfa","8612ae9a-f53c-5bf4-2899-8174d7abc4fd","12467401-e979-2c49-34e0-6ac761542797","d53c3eaa-0404-3860-0675-3e375596c3e3","9f5b26bd-81d3-b25e-62fe-5b671d1e3e79","f57f0b64-a050-d617-ee00-c8e9e3adc9cb","beff166a-f5f3-f05e-e020-98f2b00e27ed","02278a65-94ba-6d5e-0d2b-93f2e4f4bf70","a707197d-449e-5b58-846c-0c850c61f9d6","021d4b1a-9503-a44f-ee2b-976eb5d80e68","0ae2ffae-7265-524d-cb76-c2b691992706","f6e41cf2-1104-bd0b-0190-dffad1bac813","2b4bb15e-956d-56ae-69f5-d26a20de0ce7","f816da2c-51f1-612a-2029-a542db7db882","345fea05-c7be-465c-409f-9dcb3bd2aa07","b3017e02-c063-5185-acd5-1ef5f9d79b89","4dcff365-1971-3c2b-d73c-77e1dc54242a"];
 
///////////// END CONSTANTS ////////////////
 
///////////// GLOBAL VARIABLES ///////////////
// All displayable characters.  Default to ASCII order.
string gCharIndex;
// This is the channel to listen on while acting
// as a cell in a larger display.
integer gCellChannel = -1;
// This is the starting character position in the cell channel message
// to render.
integer gCellCharPosition = 0;
// This is whether or not to use the fade in/out special effect.
integer gCellUseFading = FALSE;
// This is how long to display the text before fading out (if using
// fading special effect).
// Note: < 0  means don't fade out.
float gCellHoldDelay = 1.0;
/////////// END GLOBAL VARIABLES ////////////
 
ResetCharIndex(){
    (gCharIndex = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`");
    (gCharIndex += "abcdefghijklmnopqrstuvwxyz{|}~");
    (gCharIndex += "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
}
 
vector GetGridPos(integer index1,integer index2){
    integer Col;
    integer Row;
    if ((index1 >= index2)) {
        (Row = index1);
        (Col = (index2 * 2));
    }
    else  {
        (Row = index2);
        (Col = ((index1 * 2) + 1));
    }
    return <Col,Row,0>;
}
 
string GetGridTexture(vector grid_pos){
    integer GridCol = (llRound(grid_pos.x) / 20);
    integer GridRow = (llRound(grid_pos.y) / 10);
    key Texture = llList2Key(CHARACTER_GRID,(((GridRow * (GridRow + 1)) / 2) + GridCol));
    return Texture;
}
 
vector GetGridOffset(vector grid_pos){
    integer Col = (llRound(grid_pos.x) % 20);
    integer Row = (llRound(grid_pos.y) % 10);
    return <((-0.45) + (5.0e-2 * Col)),(0.45 - (0.1 * Row)),0.0>;
}
 
ShowChars(vector grid_pos1,vector grid_pos2,vector grid_pos3,vector grid_pos4,vector grid_pos5){
    llSetPrimitiveParams([PRIM_TEXTURE,FACE_1,GetGridTexture(grid_pos1),<0.25,0.1,0>,(GetGridOffset(grid_pos1) + <7.5e-2,0,0>),0.0,PRIM_TEXTURE,FACE_2,GetGridTexture(grid_pos2),<0.1,0.1,0>,GetGridOffset(grid_pos2),0.0,PRIM_TEXTURE,FACE_3,GetGridTexture(grid_pos3),<(-1.48),0.1,0>,(GetGridOffset(grid_pos3) + <0.37,0,0>),0.0,PRIM_TEXTURE,FACE_4,GetGridTexture(grid_pos4),<0.1,0.1,0>,GetGridOffset(grid_pos4),0.0,PRIM_TEXTURE,FACE_5,GetGridTexture(grid_pos5),<0.25,0.1,0>,(GetGridOffset(grid_pos5) - <7.5e-2,0,0>),0.0]);
}
 
RenderString(string str){
    vector GridPos1 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,0,0)),llSubStringIndex(gCharIndex,llGetSubString(str,1,1)));
    vector GridPos2 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,2,2)),llSubStringIndex(gCharIndex,llGetSubString(str,3,3)));
    vector GridPos3 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,4,4)),llSubStringIndex(gCharIndex,llGetSubString(str,5,5)));
    vector GridPos4 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,6,6)),llSubStringIndex(gCharIndex,llGetSubString(str,7,7)));
    vector GridPos5 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,8,8)),llSubStringIndex(gCharIndex,llGetSubString(str,9,9)));
    ShowChars(GridPos1,GridPos2,GridPos3,GridPos4,GridPos5);
}
 
RenderWithEffects(string str){
    vector GridPos1 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,0,0)),llSubStringIndex(gCharIndex,llGetSubString(str,1,1)));
    vector GridPos2 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,2,2)),llSubStringIndex(gCharIndex,llGetSubString(str,3,3)));
    vector GridPos3 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,4,4)),llSubStringIndex(gCharIndex,llGetSubString(str,5,5)));
    vector GridPos4 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,6,6)),llSubStringIndex(gCharIndex,llGetSubString(str,7,7)));
    vector GridPos5 = GetGridPos(llSubStringIndex(gCharIndex,llGetSubString(str,8,8)),llSubStringIndex(gCharIndex,llGetSubString(str,9,9)));
    llSetAlpha(5.0e-2,ALL_SIDES);
    ShowChars(GridPos1,GridPos2,GridPos3,GridPos4,GridPos5);
    float Alpha;
    for ((Alpha = 0.1); (Alpha <= 1.0); (Alpha += 5.0e-2)) llSetAlpha(Alpha,ALL_SIDES);
    if ((gCellHoldDelay < 0.0)) return;
    llSleep(gCellHoldDelay);
    for ((Alpha = 0.95); (Alpha >= 5.0e-2); (Alpha -= 5.0e-2)) llSetAlpha(Alpha,ALL_SIDES);
    llSetTexture(TRANSPARENT,ALL_SIDES);
}
 
RenderExtended(string str){
    list Parsed = llParseString2List(str,[],[ESCAPE_SEQUENCE]);
    integer ParsedLen = llGetListLength(Parsed);
    list Indices;
    integer IndicesLeft = 10;
    integer i;
    string Token;
    integer Clipped;
    integer LastWasEscapeSequence = FALSE;
    for ((i = 0); ((i < ParsedLen) && (IndicesLeft > 0)); (i++)) {
        (Token = llList2String(Parsed,i));
        if ((Token == ESCAPE_SEQUENCE)) {
            (LastWasEscapeSequence = TRUE);
        }
        else  {
            (Clipped = FALSE);
            integer TokenLength = llStringLength(Token);
            if ((TokenLength > IndicesLeft)) {
                (Token = llGetSubString(Token,0,(IndicesLeft - 1)));
                (TokenLength = llStringLength(Token));
                (IndicesLeft = 0);
                (Clipped = TRUE);
            }
            else  (IndicesLeft -= TokenLength);
            if (LastWasEscapeSequence) {
                (Indices += [(llSubStringIndex(EXTENDED_INDEX,llGetSubString(Token,0,0)) + 95)]);
                integer j;
                for ((j = 1); (j < TokenLength); (j++)) (Indices += [llSubStringIndex(gCharIndex,llGetSubString(Token,j,j))]);
            }
            else  {
                integer j;
                for ((j = 0); (j < TokenLength); (j++)) (Indices += [llSubStringIndex(gCharIndex,llGetSubString(Token,j,j))]);
            }
            (LastWasEscapeSequence = FALSE);
        }
    }
    vector GridPos1 = GetGridPos(llList2Integer(Indices,0),llList2Integer(Indices,1));
    vector GridPos2 = GetGridPos(llList2Integer(Indices,2),llList2Integer(Indices,3));
    vector GridPos3 = GetGridPos(llList2Integer(Indices,4),llList2Integer(Indices,5));
    vector GridPos4 = GetGridPos(llList2Integer(Indices,6),llList2Integer(Indices,7));
    vector GridPos5 = GetGridPos(llList2Integer(Indices,8),llList2Integer(Indices,9));
    ShowChars(GridPos1,GridPos2,GridPos3,GridPos4,GridPos5);
}
 
integer ConvertIndex(integer index){
    if ((index >= 32)) (index -= 32);
    else  {
        if ((index > 15)) (index = 15);
        (index += 94);
    }
    return index;
}
 /***********************************************
*  s()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return a string
***********************************************/
string s(string ss){
    return llList2String(llParseString2List(ss,[":"],[]),1);
}
/***********************************************
*  i()  used so that sending of linked messages is more readable by humans.  Ie: instead of sending a linked message as
*  GETDATA|50091bcd-d86d-3749-c8a2-055842b33484 
*  Context is added instead: COMMAND:GETDATA|PLAYERUUID:50091bcd-d86d-3749-c8a2-055842b33484
*  All this function does is strip off the text before the ":" char and return an integer
***********************************************/

integer i(string ii){
    return llList2Integer(llParseString2List(ii,[":"],[]),1);
}
default {

    state_entry() {
        ResetCharIndex();
        list xyTextData = llParseString2List(llGetLinkName(llGetLinkNumber()),[","],[]);
        (myCell = i(llList2String(xyTextData,0)));
        (myRow = i(llList2String(xyTextData,1)));
        (myType = s(llList2String(xyTextData,2)));
        (gCellChannel = i(llList2String(xyTextData,3)));
        (gCellCharPosition = i(llList2String(xyTextData,4)));
    }

 
    link_message(integer sender,integer channel,string data,key id) {
        if ((channel == DISPLAY_STRING)) {
            RenderString(data);
            return;
        }
        if ((channel == DISPLAY_EXTENDED)) {
            RenderExtended(data);
            return;
        }
        if ((channel == gCellChannel)) {
            string TextToRender = llGetSubString(data,gCellCharPosition,(gCellCharPosition + 9));
            if (gCellUseFading) RenderWithEffects(TextToRender);
            else  RenderString(TextToRender);
            return;
        }
        if ((channel == REMAP_INDICES)) {
            list Parsed = llCSV2List(data);
            integer i;
            for ((i = 0); (i < llGetListLength(Parsed)); (i += 2)) {
                integer Index1 = ConvertIndex(llList2Integer(Parsed,i));
                integer Index2 = ConvertIndex(llList2Integer(Parsed,(i + 1)));
                string Value1 = llGetSubString(gCharIndex,Index1,Index1);
                string Value2 = llGetSubString(gCharIndex,Index2,Index2);
                (gCharIndex = llDeleteSubString(gCharIndex,Index1,Index1));
                (gCharIndex = llInsertString(gCharIndex,Index1,Value2));
                (gCharIndex = llDeleteSubString(gCharIndex,Index2,Index2));
                (gCharIndex = llInsertString(gCharIndex,Index2,Value1));
            }
            return;
        }
        if ((channel == RESET_INDICES)) {
            ResetCharIndex();
            return;
        }
        if ((channel == SET_THICKNESS)) {
            vector Scale = llGetScale();
            float Thickness = ((float)data);
            integer ThisLink = llGetLinkNumber();
            if (((ThisLink != 0) || (ThisLink != 1))) {
                vector Up = llRot2Up(llGetLocalRot());
                float DistanceToMove = ((Thickness / 2.0) - (Scale.z / 2.0));
                vector Pos = llGetLocalPos();
                llSetPos((Pos + (DistanceToMove * Up)));
            }
            (Scale.z = Thickness);
            llSetScale(Scale);
            return;
        }
        if ((channel == SET_COLOR)) {
            vector newColor = ((vector)data);
            llSetColor(newColor,ALL_SIDES);
        }
    }
}
// Please leave the following line intact to show where the script lives in Subversion:
// SLOODLE LSL Script Subversion Location: mod/awards-1.0/lsl/xytext_prims/xytext.lsl 
