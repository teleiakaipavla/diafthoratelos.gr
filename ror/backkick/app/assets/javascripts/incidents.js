$(function() {

    $("#public_entity_category_id").change(function() {
	$.ajax({
	    type: 'POST',
	    url: '/public_entities/category',
	    data: {
		category_id: $(this).val()
	    }
	});
    });
    
    $("#public_entity_name").autocomplete({
	source: "/public_entities/search",
	minLength: 2
    });

});
