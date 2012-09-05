var RecaptchaOptions = {
    tabindex: 1,
    theme: 'custom',
    custom_theme_widget: 'recaptcha_widget'
};

$(function() {

    var category_id_val = "";

    $("#public_entity_category_id").change(function() {
	category_id_val = $(this).val();
    });
    
    $("#public_entity_name").autocomplete({
	source: function(request, response) {
	    $.ajax({
		url: "/public_entities/search",
		dataType: "json",
		data: {
		    term: request.term,
		    category_id: category_id_val,
		},
		success: function(data) {
		    response($.map(data, function(item) {
			return {
			    label: item.label,
			    value: item.value
			}}))},
	    })},
	minLength: 2,
	select: function(event, ui) {
	    $(this).val(ui.item.label);
	},
    });

});
