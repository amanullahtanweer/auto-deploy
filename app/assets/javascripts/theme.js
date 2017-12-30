$('.ps-container').perfectScrollbar();

$( document ).on('turbolinks:load', function() {


	$('#search_fields_button').click(function(event) {
		event.preventDefault();
		$( ".search_fields_box" ).slideToggle();
	});

	$("#reset").on("click", function () {
		window.location = $(this).attr('data-path')
	});

	$("tr td").on("click", function () {
		var link = $(this).attr('data-link')
		if (link) {
			window.location = link
		}
	});

	var submit_button = $("input[type='submit']")
	submit_button.click(function(){
		$("form").submit();
	});


	$('*[data-keybinding]').each(function(i, el) {
		var bindedKey;
		bindedKey = $(el).data('keybinding');
		if (typeof bindedKey === 'number') {
			bindedKey = bindedKey.toString();
		}
		return Mousetrap.bind(bindedKey, function(e) {
			if (typeof Turbolinks === 'undefined') {
				return el.click();
			} else {
				return Turbolinks.visit(el.href);
			}
		});
	});

	Mousetrap.bind('shift+backspace', function(e){
		window.history.back();
	});

	Mousetrap.bind("shift+?", function(e) {
		$('tr').hover();
	});

	$("textarea").each(function() {
    CodeMirror.fromTextArea($(this).get(0), {
      lineNumbers: true
    });
  });

});
