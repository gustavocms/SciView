$(document).ready(function() {
  $('.chart').each(function(i,el){   
    window.chart = new SciView.FocusChart({
      element: el,
      url: d3.select(el).attr('data-source-url')
    })

    chart.getData()

  });
});

$(function() {
    var series_key = $( "#series-key" ),
        dialog_tag = $( "#dialog-tag" ),
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
                var closeDialog = false;

                allFields.removeClass( "ui-state-error" );

                if ( checkLength(dialog_tag)) {

                    var tag = dialog_tag.val();
                    $.ajax({
                        url: "/datasets/" + series_key.text() + "/tags",
                        type: "POST",
                        dataType: "json",
                        data: {"tag":tag},
                        async: false,
                        success: function() {
                            addTagButton(tag);
                            closeDialog = true;
                        }
                    });
                }

                if (checkLength(dialog_key) && checkLength(dialog_value)) {

                    var attribute = dialog_key.val(),
                        value = dialog_value.val()
                    $.ajax({
                        url: "/datasets/" + series_key.text() + "/attributes",
                        type: "POST",
                        dataType: "json",
                        data: {"attribute":attribute,"value":value},
                        async: false,
                        success: function() {
                            addAttributeButton(attribute,value);
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

    $( "#addMetadata" )
        .button({icons: {primary: "ui-icon-plusthick"}, text: false}) // Ask jQuery UI to buttonize it
        .click(function() {
            $( "#dialog-form" ).dialog( "open" );
        });
});

loadMetadata = function(){

    $("#series-key").text(String(chart._data[0].key));

    $.each( chart._data[0].tags, function( index, value ){
      addTagButton (value);
    });

    $.each( chart._data[0].attributes, function( key, value ) {
      addAttributeButton (key, value);
    });

}

addTagButton = function(tag){
    var tagButton=$('<button>' + tag + '</button>') // Create the element
        .button({icons: {secondary: "ui-icon-closethick"}}) // Ask jQuery UI to buttonize it
        .click(function(){ removeTag( $("#series-key").text(), tag, this ); }); // Add a click handler

    $('#series-metadata')
        .append(tagButton);
};

addAttributeButton = function(key, value){
    var attrButton=$('<button>' + key + ':' + value + '</button>') // Create the element
        .button({icons: {secondary: "ui-icon-closethick"}}) // Ask jQuery UI to buttonize it
        .click(function(){ removeAttribute( $("#series-key").text(), key, this ); }); // Add a click handler

    $('#series-metadata')
        .append(attrButton);
}

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
