(function($) {
    function calendarWidget(element, params) {
        // Default to todays date if we don't pass anything
        var now = new Date();
        var o = {
            month: now.getMonth(),
            year:  now.getFullYear(),
            dayNames:   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        };

        $.extend(o, params);

        // To show 6 rows of 7 days, we need to calculate the 42 days
        // that wholly contain our current month
        var startDate = new Date(o.year, o.month, 1);

        // Find the Sunday closest to the 1st of our selected month
        startDate.setDate(startDate.getDate()-startDate.getDay());
        
        // A calendar is semantically closest to a table. So lets show it as one.
        var table = '<table class="datepicker"><tr>';
        table += '<th colspan="2"><a href="#" id="prev-month">&larr;</a></th>';
        table += '<th colspan="3" id="current-month" data-year="'+o.year+'" data-month="'+o.month+'">'+o.monthNames[o.month]+' '+o.year+'</th>';
        table += '<th colspan="2"><a href="#" id="next-month">&rarr;</a></th>';
        table += '</tr><tr>';

        // Day of the week header
        table += '</tr><tr>';
        for (d=0; d<7; d++) {
            table += '<th class="weekday">' + o.dayNames[d] + '</th>';
        }
        table += '</tr><tr>';

        // Show the following 42 days from our start date. 6 rows of 7 days each
        for (d=0; d<42; d++) {
            if (d % 7 == 0 && d != 41 && d != 0) {
                table += '</tr><tr>';
            }

            var td_class = 'current-month';
            if (startDate.getMonth() != o.month) {
                td_class = 'other-month';
            }

            // WTF JavaScript? Y U NO HAVE SPRINTF?
            // Also, Months are zero indexed, but dates start at 1, hence the parseInt() Go figure.
            var paddedDate  = (startDate.getDate() < 10) ? ("0" + startDate.getDate()) : startDate.getDate(),
                paddedMonth = (startDate.getMonth() < 9) ? ("0" + parseInt(startDate.getMonth() + 1) ) : startDate.getMonth() + 1;

            table += '<td class='+ td_class +'>';
            table += '<a href="'+ startDate.getFullYear() +'-'+ paddedMonth +'-'+ paddedDate +'">'+ startDate.getDate() +'</a>';
            table += '</td>';
            startDate.setDate(startDate.getDate() + 1);
        }

        table += '</tr></table>';

        // Replace the elements HTML with our swanky new table
        element.html(table);
    }

    // Make it a jQuery plugin
    $.fn.calendarWidget = function(params) {
        calendarWidget(this, params);
        return this; 
    }; 

})(jQuery);
