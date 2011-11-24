(function($) { 
   
    function calendarWidget(el, params) { 

        var o = {
            day_names:   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            month_names: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        };

        $.extend(o, params);

        // To show 6 rows of 7 days, we need to calculate the 42 days
        // that wholly contain our current month
        var start_date = new Date(params.year, params.month, 1);

        // Find the Sunday closest to the 1st of our selected month
        start_date.setDate(start_date.getDate()-start_date.getDay());

        // Show the following 42 days from our start date. 6 rows of 7 days each
        var table = '<table class="datepicker"><tr>';
        table += '<th colspan="2"><a href="#" id="prev-month">&larr;</a></th>';
        table += '<th colspan="3" id="current-month" data-year="'+o.year+'" data-month="'+o.month+'">'+o.month_names[o.month]+' '+o.year+'</th>';
        table += '<th colspan="2"><a href="#" id="next-month">&rarr;</a></th>';
        table += '</tr><tr>';

        // Each individual day
        for (d=0; d<42; d++) {
            if (d % 7 == 0 && d != 41 && d != 0) {
                table += '</tr><tr>';
            }

            var td_class = 'current-month';
            if (start_date.getMonth() != params.month) {
                td_class = 'other-month';
            }

            table += '<td class='+ td_class +'><a>'+ start_date.getDate() +'</a></td>';
            start_date.setDate(start_date.getDate() + 1);
        }

        table += '</tr></table>';

        // Replace the elements HTML with our swanky new table
        el.html(table);
    }

    // jQuery plugin initialisation
    $.fn.calendarWidget = function(params) {    
        calendarWidget(this, params);        
        return this; 
    }; 

})(jQuery);
