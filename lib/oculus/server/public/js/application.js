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

function QueryEditor(form, options) {
  this._form = form;
  this._options = options || {};
  this.initCodeMirror();
  this.bindEvents();
}

QueryEditor.MONITOR_TIMEOUT = 1000;

QueryEditor.prototype.getQueryField = function() {
  return document.getElementById('query-field');
}

QueryEditor.prototype.focus = function() {
  this._codeMirror.focus();
}

QueryEditor.prototype.initCodeMirror = function() {
  this._codeMirror = CodeMirror.fromTextArea(this.getQueryField(), {
    tabSize: 2
  });
}

QueryEditor.prototype.bindEvents = function() {
  var self = this;
  $(document).on('keydown', 'form', function(e) {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();

      // CodeMirror normally saves itself automatically, but since there is no
      // 'submit' event fired, we need to notify CodeMirror manually.
      self._codeMirror.save();

      self.submit();
    }
  });
  this._form.on('submit', function(e) {
    e.preventDefault();
    self.submit();
  });
}

QueryEditor.prototype.submit = function() {
  if(this._options.onQueryStart) this._options.onQueryStart();

  var self = this;
  $.ajax({
    url: this._form.attr('action'),
    type: 'POST',
    data: this._form.serialize(),
    dataType: 'json',
    success: function(data) {
      self.monitorQuery(data.id);
    },
    error: function() {
      if (self._options.onQueryError) self._options.onQueryError();
    }
  });
}

QueryEditor.prototype.monitorQuery = function(id) {
  this._monitorQueryId = id;

  var self = this;
  setTimeout(function() {
    self._tick();
  }, QueryEditor.MONITOR_TIMEOUT);
}

QueryEditor.prototype._tick = function() {
  if (this._monitorQueryId) {
    var queryId = this._monitorQueryId,
        self    = this;

    $.ajax({
      url: '/queries/' + queryId + '/status',
      type: 'GET',
      success: function(status) {
        // Ignore responses for queries we're no longer interested in
        if (queryId === self._monitorQueryId) {
          if (status !== 'loading') {
            self._loadQueryResult(queryId);
          } else {
            setTimeout(function() {
              self._tick();
            }, QueryEditor.MONITOR_TIMEOUT);
          }
        }
      }
    });
  }
}

QueryEditor.prototype._loadQueryResult = function(id) {
  var self = this;
  $.ajax({
    url: '/queries/' + id + '.json',
    type: 'GET',
    dataType: 'json',
    success: function(data) {
      // Ignore responses for queries we're no longer interested in
      if (id === self._monitorQueryId) {
        if (data.results) {
          if (self._options.onQuerySuccess) self._options.onQuerySuccess(data);
        } else {
          if (self._options.onQueryError) self._options.onQueryError(data.error);
        }
      }
    },
    error: function() {
      if (id === self._monitorQueryId && self._options.onQueryError) {
        self._options.onQueryError("Failed to load results");
      }
    }
  });
}
