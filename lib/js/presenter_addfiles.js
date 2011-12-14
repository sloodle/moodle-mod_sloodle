function startUpload(id){  ;
        if (qSize < uploadLimit)
            $('#fileInput').fileUploadStart();
    }        $(document).ready(function() {
		var scriptData = {
			'cmid':cmid, 
			'itemid':itemid,
			'signature':signature,
			'signeddata':signeddata
		}
		//scriptData[ sessioncookiename ] = sessioncookievalue;
		$("#uploadButton").hide();$('#fileInput').fileUpload ({'uploader'  : 'lib/multiplefileupload/uploader.swf','script'    : 'lib/multiplefileupload/upload.php','scriptData' : scriptData,'multi'     :  true,'cancelImg' : 'lib/multiplefileupload/cancel.png','buttonText': 'Select Files','auto'      : false,'folder'    : 'uploads','fileDesc'  : 'jpg;png;gif;htm;html;mov','fileExt'   :   '*.jpg;*.png;*.gif;*.htm;*.html;*.mov',onError: function (a, b, c, d) {
         if (d.status == 404)
            alert('Could not find upload script.');
         else if (d.type === "HTTP")
            alert('error '+d.type+": "+d.status);
         else if (d.type ==="File Size")
            alert(c.name+' '+d.type+' Limit: '+Math.round(d.sizeLimit/1024)+'KB');
         else
            alert('error '+d.type+": "+d.text);
},        'onAllComplete': function() {uploadArray.sort();var fileDisplayArea = $("#filesUploaded");fileDisplayArea.append($ ('<div id="fileTables"></div>'));var jList = $( "#fileTables" );$.each(uploadArray,function( intIndex, objValue ){var start = objValue.length-4;extension=objValue.substr(start,4);extension=extension.toLowerCase();var fname = objValue.substr(0,objValue.length-4);tableData= '<table ><tr><td width=100>Name:</td><td> <input type="text" id="filename"  name="filename[]" value="'+fname.replace(' \(','_\(').replace('\) ','\)_').replace(' ','_').replace(' ','_')+'" size="60" maxlength="255" /></td><td width="100">';if ((extension=='.jpg') || (extension=='.gif') || (extension=='.png')) {tableData += '<label>Type:</label><select name="ftype[]" id="type" size="1"><option name=""  value="">image</option></select></td></tr></table>';tableData += '<table ><tr><td><img src="'+uploadWwwDir+objValue.replace(' \(','_\(').replace('\) ','\)_').replace(' ','_')+'" width="100" height="100"></td></tr></table>';} else if (extension=='.mov') {tableData+=  '<label>Type:</label><select name="" id="type" size="1"><option name="" value="">video</option></select></td></tr></table>';tableData += '<table ><tr><td><embed src="'+uploadWwwDir+objValue.replace(' \(','_\(').replace('\) ','\)_').replace(' ','_')+'" width="100" height="100" autohref="false"></td></tr></table>'} else if ((extension=='.htm') ||(extension=='html'))  {tableData+= '<label>Type:</label><select name="" id="type" size="1"><option name=""   value="">web</option></select></td></tr></table>';}tableData+='<table ><tr><td width=100>Url:</td><td><input type="text"  id="fileurl" name="fileurl[]" value="'+uploadWwwDir+objValue.replace(' \(','_\(').replace('\) ','\)_').replace(' ','_').replace(' ','_')+'" size="60" maxlength="255" /></td></tr></table><HR>';jList.append($ (tableData)); });jList.append($ ('<input type="submit" value="Add the above files to the presentation" name="fileaddentry" />')); $("#uploadButton").hide(); $("#qSize").hide();qSize=0; },                'onSelect': function (event,queueID,fileObj){
                   $("#qSize").show();
              qSize += fileObj.size;
               if (qSize > uploadLimit){
                 $("#uploadButton").hide();
                 $("#qSize").css("color","red");
                 $("#qSize").text("Error: You have selected "+qSize+ " bytes to upload. Bulk upload size is limited to: "+uploadLimit);
              } else 
              { 
                $("#uploadButton").show();
                $("#qSize").css("color","blue");
                $("#qSize").html(qSize+" bytes selected. <b>"+(uploadLimit-qSize) + "</b> bytes available to queue");
              }

        
        },
        
               'onCancel': function (event,queueID,fileObj){
              qSize -= fileObj.size;
              
              if (qSize > uploadLimit){
                $("#uploadButton").hide();
                $("#qSize").css("color","red");
                $("#qSize").text("Error: You have selected "+qSize+ " bytes to upload. Bulk upload size is limited to: "+uploadLimit);
              } else 
              { 
                $("#uploadButton").show();
                $("#qSize").css("color","blue");
                $("#qSize").html(qSize+" bytes selected. <b>"+(uploadLimit-qSize) + "</b> bytes available to queue");
              }
              
        
        },
        'onComplete': function(event, queueID, fileObj, response, data) {uploadArray[uploadArrayLen]=fileObj.name;uploadArrayLen++;$('#fileTables').remove();}    });   });

