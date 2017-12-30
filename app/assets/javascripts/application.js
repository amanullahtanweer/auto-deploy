//= require jquery3
//= require jquery_ujs
//= require mousetrap
//= require popper
//= require cable
//= require bootstrap
//= require perfect-scrollbar
//= require codemirror
//= require codemirror/modes/ruby
//= require codemirror/modes/shell
//= require codemirror/modes/nginx
//= require turbolinks
//= require theme
//= require subscription
$("textarea").each(function() {
    CodeMirror.fromTextArea($(this).get(0), {
      lineNumbers: true
    });
});

$('pre').each(function() {

    var $this = $(this),
        $code = $this.html();

    $this.empty();

    var myCodeMirror = CodeMirror(this, {
        value: $code,
        mode: 'javascript',
        lineNumbers: !$this.is('.inline'),
        readOnly: true
    });

});