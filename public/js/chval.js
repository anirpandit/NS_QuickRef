//For message alerts at top of page//
$(document).ready(function() {

	$.validator.setDefaults({ ignore: ":hidden:not(.chosen-select)" }); //for all select having class .chosen-select
	$("#searchform").validate();
	$("#newform").validate();
	$("#editform").validate();
    $.validator.addClassRules("searchformval", {
        require_from_group: [1, ".searchformval"]
    });
});