//Modal for delete//
        $('#confirm-delete').on('show.bs.modal', function(e) {
            $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
        });

//For message alerts at top of page//
$(document).ready(function() {
	$(".alert").delay(4000).slideUp(200, function() {
    	$(this).alert('close');
	});
	
	$('table.display').DataTable();
});

//Code for Chosen Jquery plugin//
var config = {
    '.chosen-select'           : {},
    '.chosen-select-deselect'  : {allow_single_deselect:true},
	'.chosen-select-no-single' : {disable_search_threshold:10},
	'.chosen-select-no-results': {no_results_text:'Oops, nothing found!'},
	'.chosen-select-width'     : {width:"95%"}
}
for (var selector in config) {
	$(selector).chosen(config[selector]);
}