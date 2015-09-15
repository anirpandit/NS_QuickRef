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


$('a[href^="#"]').on('click', function(event) {

    var target = $( $(this).attr('href') );

    if( target.length ) {
        event.preventDefault();
        $('html, body').animate({
            scrollTop: target.offset().top
        }, 1000);
    }

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


function checkFields(form) {
        var checks_radios = form.find(':checkbox, :radio'),
            inputs = form.find(':input').not(checks_radios).not('[type="submit"],[type="button"],[type="reset"]'); 
        
        var checked = checks_radios.filter(':checked');
        var filled = inputs.filter(function(){
            return $.trim($(this).val()).length > 0;
        });
        
        if(checked.length + filled.length === 0) {
            return false;
        }
        
        return true;
    }
