(function($){
    $.fn.simpleAlerter = function(alertDuration){

        var element = this;
        
        if($(element).length)
	    {
	        $(element).fadeIn("slow");	
    		
		    if(alertDuration)
		    {
                var alerttimer = window.setTimeout(function(){
			        $(element).trigger('click');
			    }, alertDuration);
            }
            $(element).click(function(){
	            window.clearTimeout(alerttimer);
			    $(element).fadeOut("slow");					
		    });
        }
    };
})(jQuery);
