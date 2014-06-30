initMetadataDialog = function(){
    var dialog_tag = $( "#dialog-tag" ),
        dialog_key = $( "#dialog-key" ),
        dialog_value = $( "#dialog-value" ),
        allFields = $( [] ).add( dialog_tag ).add( dialog_key ).add( dialog_value );

    $( "#dialog-form" ).dialog({
        autoOpen: false,
        height: 400,
        width: 500,
        modal: true,
        buttons: {
            Cancel: function() {
                $( this ).dialog( "close" );
            },
            "Add": function() {
                var series_key = $("#dialog-form").data('series_key')
                var closeDialog = false;

                allFields.removeClass( "ui-state-error" );

                if ( checkLength(dialog_tag)) {

                    var tag = dialog_tag.val();
                    $.ajax({
                        url: "/datasets/" + series_key + "/tags",
                        type: "POST",
                        dataType: "json",
                        data: {"tag":tag},
                        async: false,
                        success: function() {
                            addTagButton(series_key, tag);
                            closeDialog = true;
                        }
                    });
                }

                if (checkLength(dialog_key) && checkLength(dialog_value)) {

                    var attribute = dialog_key.val(),
                        value = dialog_value.val()
                    $.ajax({
                        url: "/datasets/" + series_key + "/attributes",
                        type: "POST",
                        dataType: "json",
                        data: {"attribute":attribute,"value":value},
                        async: false,
                        success: function() {
                            addAttributeButton(series_key, attribute, value);
                            closeDialog = true;
                        }
                    });
                }

                if (closeDialog == true) {
                    $( this ).dialog( "close" );
                }
            }
        },
        close: function() {
            allFields.val( "" ).removeClass( "ui-state-error" );
        }
    });
};

loadMetadata = function(){

    $.each( chart._data, function( index, data ){

        addContainerDiv (data.key);

        addNewButton (data.key);

        $.each( data.tags, function( i, tag ){
            addTagButton (data.key, tag);
        });

        $.each( data.attributes, function( attribute, value ) {
            addAttributeButton (data.key, attribute, value);
        });
    });
};

addContainerDiv = function(series_key) {
    var dataDiv=$('<div id="serie_' + series_key + '"></div>')
    dataDiv.append('<h3>' + series_key + ' Tags and Attributes</h3>');

    $('#series-metadata').append(dataDiv);
};

addNewButton =  function(series_key) {
    var seriesDivID = 'serie_' + series_key;

    var newButton=$('<button id="addMetadata_' + series_key + '">New</button>') // Create the element
        .button({icons: {primary: "ui-icon-plusthick"}, text: false}) // Ask jQuery UI to buttonize it
        .click(function() {
            $( "#dialog-form" )
                .data('series_key', series_key)
                .dialog( "open" );
        });

    $('#' + seriesDivID)
        .append(newButton);
};

addTagButton = function(series_key, tag){
    var seriesDivID = 'serie_' + series_key;
    var tagButtonID = 'tag_' + tag;

    //avoid invalid names like "`1234567890!@#$%^&*()" (will be ignored)
    try {
        var tagButton=$( '#' + seriesDivID + ' > #' + tagButtonID );
    } catch(e) {
        // handle all your exceptions here
    }

    //check if selector worked (otherwise wont create this tag button)
    if (tagButton) {

        //if button exists, do not create again
        if (!tagButton.length) {

            tagButton = $('<button id="' + tagButtonID + '">' + tag + '</button>') // Create the element
                .button({icons: {secondary: "ui-icon-closethick"}}) // Ask jQuery UI to buttonize it
                .click(function () {
                    removeTag(series_key, tag, this);
                }); // Add a click handler

            $('#' + seriesDivID)
                .append(tagButton);
        }
    }
};

addAttributeButton = function(series_key, attribute, value){
    var seriesDivID = 'serie_' + series_key;
    var attrButtonID = 'attribute_' + attribute;

    //avoid invalid names like "`1234567890!@#$%^&*()" (will be ignored)
    try {
        var attrButton=$( '#' + seriesDivID + ' > #' + attrButtonID );
    } catch(e) {
        // handle all your exceptions here
    }

    //check if selector worked (otherwise wont create this attribute button)
    if (attrButton) {

        //if button exists, remove before adding again
        if (attrButton.length) {
            attrButton.remove();
        }

        attrButton = $('<button id="' + attrButtonID + '">' + attribute + ':' + value + '</button>') // Create the element
            .button({icons: {secondary: "ui-icon-closethick"}}) // Ask jQuery UI to buttonize it
            .click(function () {
                removeAttribute(series_key, attribute, this);
            }); // Add a click handler

        $('#' + seriesDivID)
            .append(attrButton);
    }
};

removeTag = function(series_key, tag, sender) {
    $('<div></div>').appendTo('body')
        .html('<div><h6>Are you sure?</h6></div>')
        .dialog({
            modal: true,
            resizable: false,
            title: 'Remove Tag',
            width: 'auto',
            buttons: {
                "Delete": function () {
                    $.ajax({
                        url: "/datasets/" + series_key + "/tags/" + tag,
                        type: "DELETE",
                        async: false,
                        success: function(data) {
                            sender.remove();
                        }
                    });

                    $(this).dialog("close");
                },
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            close: function (event, ui) {
                $(this).remove();
            }
        });
};

removeAttribute = function(series_key, attribute, sender) {
    $('<div></div>').appendTo('body')
        .html('<div><h6>Are you sure?</h6></div>')
        .dialog({
            modal: true,
            resizable: false,
            title: 'Remove Attribute',
            width: 300,
            buttons: {
                "Delete": function () {
                    $.ajax({
                        url: "/datasets/" + series_key + "/attributes/" + attribute,
                        type: "DELETE",
                        async: false,
                        success: function(data) {
                            sender.remove();
                        }
                    });

                    $(this).dialog("close");
                },
                Cancel: function () {
                    $(this).dialog("close");
                }
            },
            close: function (event, ui) {
                $(this).remove();
            }
        });
};

checkLength = function ( o ) {
    if ( o.val().length == 0  ) {
        o.addClass( "ui-state-error" );
        return false;
    } else {
        return true;
    }
};

