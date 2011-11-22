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

});