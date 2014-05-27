$(document).ready(function() {
    $('#add_more_data_sets').click(function(e){
      e.preventDefault()
      var clone = $('.field:first').clone();
      $(clone).find('.chart_dataset').val('')
      $(clone).insertAfter($('.field:last'))
    });

    $(".chart_dataset").autocomplete({
        minLength: 0,

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
            $("#chart_dataset").val(ui.item.key);
            return false;
        },

        select: function(event, ui) {
            $("#chart_dataset").val(ui.item.key);
            return false;
        }
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
        return $("<li>")
                .append("<a>" + item.key +
                        "<p style='font-size: small; padding: 0; margin: 0'>Tags:" +
                        item.tags.join(', ') + "</p></a>")
                .appendTo( ul );
    };

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
