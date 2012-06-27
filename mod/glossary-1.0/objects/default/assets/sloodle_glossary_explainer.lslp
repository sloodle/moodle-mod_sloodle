//
// The line above should be left blank to avoid script errors in OpenSim.

// NB Not sure what this script is for.
// It was in Fumi's oar, but I couldn't find anything like it in SVN.
// If anybody knows, please delete these comments and replace them with some comments explaining why it's here.
// - Edmund Edgar, 2010-11-27
default
{
    state_entry()
    {
         llSetText("Sloodle MetaGloss: Picture Glossary\nChat \"/def \" then a term to search glossary", <1, 0, 0>, 0.90);

         llRemoveInventory(llGetScriptName());
    }
}
// Please leave the following line intact to show where the script lives in Git:
// SLOODLE LSL Script Git Location: mod/glossary-1.0/objects/default/assets/sloodle_glossary_explainer.lslp
