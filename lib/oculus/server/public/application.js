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

    var el = $(this);
    var container = el.closest('li');

    $.ajax({
      url: this.href,
      action: 'DELETE',
      success: function() {
        container.remove();
      }
    });
  });
});
