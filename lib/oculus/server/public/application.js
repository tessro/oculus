$(function() {
  var container = $('#editor-container');

  if (container.length) {
    container.find('textarea').hide();
    var editor = CodeMirror(container[0]);
  }

  $('#query-form').submit(function() {
    $('#editor-container textarea').val(editor.getValue());
  });
});
