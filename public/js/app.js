$(document).ready(function() {
    $('#nick-filter').chosen();

    // Shows messages by all nicks selected
    $('#nick-filter').change(function() {
        // Hide them all
        $('ol li').hide();

        // If its the last nick, don't try to iterate over them all
        if ($('#nick-filter').val()) {
            $.each($('#nick-filter').val(), function(key, value) {
                // And turn the ones we want back on.
                $('ol li.'+value).show();
            });
        
        }
    });

    // non functional atm, but stubbed anyway.
    $('#search-box').submit(function() {
        var url_clean = $('#search-box input').val().replace(/\W+/g, '');
        $(location).attr('href',url_clean);
    });

    // Enable the drop-down
    $('.topbar').dropdown()

    $("#calendar").calendarWidget({
        month: 10,
        year: 2011
    });
 
    month_nav_bind();
          
});


function next_month() {
    var cur_month = parseInt( $('#current-month').attr('data-month') ),
        cur_year  = parseInt( $('#current-month').attr('data-year') );

    var next_month = cur_month + 1,
        next_year  = cur_year;

    if (cur_month == 11) {
        next_month = 0;
        next_year  = cur_year + 1;
    }

    $("#calendar").calendarWidget({
        month: next_month,
        year: next_year
    });

    month_nav_bind();
}

function prev_month() {
    var cur_month = parseInt( $('#current-month').attr('data-month') ),
        cur_year  = parseInt( $('#current-month').attr('data-year') );

    var prev_month = cur_month - 1,
        prev_year  = cur_year;

    if (cur_month == 0) {
        prev_month = 11;
        prev_year  = cur_year - 1;
    }

    $("#calendar").calendarWidget({
        month: prev_month,
        year: prev_year
    });

    month_nav_bind();
}

function month_nav_bind() {
    $("#next-month").click(function() {
        next_month();
    });

    $("#prev-month").click(function() {
        prev_month();
    });
}
