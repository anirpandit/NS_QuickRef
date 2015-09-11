//Modal for delete//
        $('#confirm-delete').on('show.bs.modal', function(e) {
            $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
        });


$(document).ready(function() {
	$(".alert").delay(4000).slideUp(200, function() {
    	$(this).alert('close');
	});
	
	$('table.display').DataTable();
});