$(function() {
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
