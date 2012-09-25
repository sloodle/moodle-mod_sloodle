default
{
    on_rez(integer start_param){
        llResetScript();
        }
    state_entry()
    {
       llSetText("",ZERO_VECTOR,1);
    }
}