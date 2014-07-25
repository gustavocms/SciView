$(document).ready(function() {


    var autocomplete_data = function(input) {

        $(input).autocomplete({
            minLength: 0,

            open:   function( event, ui ) {
                $('.ui-autocomplete.ui-menu').addClass('newClass');
                
            },
            
            close:  function( event, ui ) {
                $('.ui-autocomplete.ui-menu').removeClass('newClass');

            },

            source: function(request, response) {
                var term = request.term,
                    matcher = new RegExp($.ui.autocomplete.escapeRegex(term), "i");

                $.ajax({
                    url: "/datasets",
                    success: function(data) {
                        response($.grep(data, function (item) {
                            return matcher.test(item.key + item.tags.join(', '));
                        }));
                    }
                });
            },

            focus: function(event, ui) {
                $(input).val(ui.item.key);
                return false;
            },

            select: function(event, ui) {
                $(input).val(ui.item.key);
                return false;
            }
        }).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $("<li>")
                    .append("<a>" + item.key +
                            "<p style='font-size: small; padding: 0; margin: 0'>Tags:" +
                            item.tags.join(', ') + "</p></a>")
                    .appendTo( ul );
        };

    };

    $('#add_more_data_sets').click(function(e){
      e.preventDefault()
      var date = new Date;
      var id = date.getTime();
      var clone = $('.field:first').clone();
      $(clone).find('.chart_dataset').val('').attr('id', id)
      $(clone).insertAfter($('.field:last'))
      autocomplete_data('#' + id)
    });


    $("#chart_dataset").each(function(i, e){ autocomplete_data(e); });

    $("#view_chart").click(function(e) {
        e.preventDefault();
        var series = []
        var url = "/charts/multiple?"
        $(".chart_dataset").each(function function_name (i, el) {
          var obj = {};
          obj["series_" + (i + 1)] = $(el).val();
          series.push($.param(obj));
        });
        window.location = url + series.join('&')
    })
});
