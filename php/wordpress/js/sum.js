$(document).ready(function () {

	$.ajax({
	  url: '../backkick/incidents/total_given.json?r=' + (Math.random() * 11000000),
	  success: function(data) {
	    $('.master-black-hole-new .money').html(groupThousands(Math.round( data )))
	  }
	});
	
    });


