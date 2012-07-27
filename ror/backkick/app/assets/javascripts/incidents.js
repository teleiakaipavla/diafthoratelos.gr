$(function() {
    $("#public_entity_name").autocomplete({
	source: "/public_entities/search",
	minLength: 2
    });
});
