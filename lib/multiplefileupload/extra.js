  $(document).ready(function(){
     
     //hide the checkall/uncheck all text  
     $("#unselectall").hide();
     $("#unselectall2").hide();  
     $("#Go").hide(); 
     
     /*
    *  this function will toggle all check boxes in the editforms form, and also toggle the 
    *  view of the select all, unselect all text
    */
    $("#selectboxes").click(function () {
        $("#editform").toggleCheckboxes(); 
        if ($('input[name=trashslides]').attr('checked')) {
            $("#unselectall").show();                            
             $("#unselectall2").show();                            
            $("#selectall").hide();
            $("#selectall2").hide();
            
        }
        else {
            $("#unselectall").hide();                            
            $("#unselectall2").hide();                                        
            $("#selectall").show();
            $("#selectall2").show();                            
            
        }
    });
    /*
    *  this function is the same as above - but for the lower text -  will toggle all check boxes in the editforms form, and also toggle the 
    *  view of the select all, unselect all text
    */
    $("#selectboxes2").click(function () {
        $("#editform").toggleCheckboxes(); 
        if ($('input[name=trashslides]').attr('checked')) {
            $("#unselectall").show();                            
             $("#unselectall2").show();                            
            $("#selectall").hide();
            $("#selectall2").hide();
            
        }
        else {
            $("#unselectall").hide();                            
            $("#unselectall2").hide();                                        
            $("#selectall").show();
            $("#selectall2").show();                            
            
        }
    });    
    /*
    *  This function will be triggered when an item is selected in the drop down
    */
    $("#multipleProcessor").change(function() {
        //display form submit button
        $("#Go").show();
  
    });

        
});
    
