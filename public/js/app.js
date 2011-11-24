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

    // Work out the month we are currently on, so we can show the right calendar
    var pathname = window.location.pathname.split('/'),
        date     = pathname[2].split('-');

    $("#calendar").calendarWidget({
        year: date[0],
        month: date[1] - 1
    });
 
    month_nav_bind();
});


function next_month() {
    var cur_month = parseInt( $('#current-month').attr('data-month') ),
        cur_year  = parseInt( $('#current-month').attr('data-year') );

    var date = new Date(cur_year, cur_month, 1);
    date.setMonth(date.getMonth() + 1)

    $("#calendar").calendarWidget({
        month: date.getMonth(),
        year:  date.getFullYear()
    });

    month_nav_bind();
}

function prev_month() {
    var cur_month = parseInt( $('#current-month').attr('data-month') ),
        cur_year  = parseInt( $('#current-month').attr('data-year') );

    var date = new Date(cur_year, cur_month, 1);
    date.setMonth(date.getMonth() - 1)

    $("#calendar").calendarWidget({
        month: date.getMonth(),
        year:  date.getFullYear()
    });

    month_nav_bind();
}

function month_nav_bind() {
    $("#next-month").click(function() {
        next_month();
        return false;
    });

    $("#prev-month").click(function() {
        prev_month();
        return false;
    });
}
