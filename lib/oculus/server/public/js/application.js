$(function() {
  var container = $('#editor-container');

  if (container.length) {
    container.find('textarea').hide();
    var editor = CodeMirror(container[0], {
      tabSize: 2
    });
  }

  $('#query-form').submit(function() {
    $('#editor-container textarea').val(editor.getValue());
  });

  $('#history .delete').click(function(e) {
    e.preventDefault();

    var row = $(this).closest('tr');

    $.ajax({
      url: this.href,
      type: 'DELETE',
      success: function() {
        row.remove();
      }
    });
  });
});
