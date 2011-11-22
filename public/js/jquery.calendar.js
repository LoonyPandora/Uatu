(function($) { 
   
    function calendarWidget(el, params) { 
        
        var now   = new Date();
        var thismonth = now.getMonth();
        var thisyear  = now.getYear() + 1900;
        
        var opts = {
            month: thismonth,
            year: thisyear
        };
        
        $.extend(opts, params);
        
        var monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        var dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        month = i = parseInt(opts.month);
        year = parseInt(opts.year);
        var m = 0;
        var table = '';
            table += ('<table class="datepicker" cellspacing="0">');
            
            table += '<tr>';            

            table += ('<th colspan="2"><a href="#" id="prev-month">&larr;</a></th>');

            table += ('<th colspan="3" id="current-month" data-year="'+year+'" data-month="'+month+'">'+monthNames[month]+' '+year+'</th>');

            table += ('<th colspan="2"><a href="#" id="next-month">&rarr;</a></th>');

            table += '</tr>';

            table += '<tr>';            
            for (d=0; d<7; d++) {
                table += '<th class="weekday">' + dayNames[d] + '</th>';
            }
            
            table += '</tr>';
        
            var days = getDaysInMonth(month,year);
            var firstDayDate=new Date(year,month,1);
            var firstDay=firstDayDate.getDay();
            
            var prev_days = getDaysInMonth(month,year);
            var firstDayDate=new Date(year,month,1);
            var firstDay=firstDayDate.getDay();
            
            var prev_m = month == 0 ? 11 : month-1;
            var prev_y = prev_m == 11 ? year - 1 : year;
            var prev_days = getDaysInMonth(prev_m, prev_y);
            firstDay = (firstDay == 0 && firstDayDate) ? 7 : firstDay;
    
            var i = 0;
            for (j=0;j<42;j++){
              
              if ((j<firstDay)){
                table += ('<td class="other-month"><a class="day">'+ (prev_days-firstDay+j+1) +'</a></td>');
              } else if ((j>=firstDay+getDaysInMonth(month,year))) {
                i = i+1;
                table += ('<td class="other-month"><a class="day">'+ i +'</a></td>');             
              }else{
                table += ('<td class="current-month day'+(j-firstDay+1)+'"><a class="day">'+(j-firstDay+1)+'</a></td>');
              }
              if (j%7==6)  table += ('</tr>');
            }

            table += ('</table>');

        el.html(table);
    }
    
    function getDaysInMonth(month,year)  {
        var daysInMonth=[31,28,31,30,31,30,31,31,30,31,30,31];
        if ((month==1)&&(year%4==0)&&((year%100!=0)||(year%400==0))){
          return 29;
        }else{
          return daysInMonth[month];
        }
    }
    
    
    // jQuery plugin initialisation
    $.fn.calendarWidget = function(params) {    
        calendarWidget(this, params);        
        return this; 
    }; 

})(jQuery);
