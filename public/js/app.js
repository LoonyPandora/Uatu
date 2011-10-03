$(document).ready(function() {
    $('#nick-filter').chosen();

    // Shows messages by all nicks selected
    $('#nick-filter').change(function() {
        
        // Hide them all
        $('ol li').hide();
        
        $.each($('#nick-filter').val(), function(key, value) {
            
            // And turn the ones we want back on.
            $('ol li.'+value).show();
            
            console.log(key + ': ' + value);
        });

    });

});