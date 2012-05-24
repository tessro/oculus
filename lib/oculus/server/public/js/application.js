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

  $('#query-properties-form').submit(function(e) {
    e.preventDefault();

    var form = $(this);

    $.ajax({
      url: this.href,
      type: 'PUT',
      data: form.serialize(),
      success: function() {
        form.hide();

        $('.description').text(form.find('.name').val());
        $('.author').text(form.find('.author').val());
        $('#query-actions .edit').removeClass('active');
      }
    });
  });

  $('#query-actions .star').click(function() {
    var btn = $(this),
        newState = !btn.hasClass('starred');

    $.ajax({
      url: this.href,
      type: 'PUT',
      data: {
        'starred': newState
      },
      success: function() {
        btn.toggleClass('starred', newState);
      }
    });
  });

  $('#query-actions .edit').click(function() {
    $('#query-properties-form').toggle();
  });

  if ($('#query-actions .edit').hasClass('active')) {
    $('#query-properties-form').show();
  }
});

function Query(id) {
  this.id         = id;
  this._monitoring = false;
}

Query.MONITOR_TIMEOUT = 1000;

Query.prototype.cancel = function() {
  $.ajax({
    url: '/queries/' + this.id + '/cancel',
    type: 'POST'
  });
}

Query.prototype.check = function(callbacks) {
  $.ajax({
    url: '/queries/' + this.id + '/status',
    type: 'GET',
    success: callbacks.success
  });
}

// For now, multiple calls to monitor will overwrite callbacks.
// Someday, a pubsub mechanism might make sense here.
Query.prototype.monitor = function(callbacks) {
  this._monitoringCallbacks = callbacks;

  if (!this._monitoring) {
    this._monitoring = true;

    var self = this;
    setTimeout(function() {
      self._tick();
    }, Query.MONITOR_TIMEOUT);
  }
}

Query.prototype.detach = function() {
  this._monitoring          = false;
  this._monitoringCallbacks = null;
}

Query.prototype._tick = function() {
  if (this._monitoring) {
    var self = this;

    this.check({
      success: function(status) {
        // Ignore responses for queries we're no longer interested in
        if (self._monitoring) {
          if (status !== 'loading') {
            self.load(self._monitoringCallbacks);
          } else {
            setTimeout(function() {
              self._tick();
            }, Query.MONITOR_TIMEOUT);
          }
        }
      }
    });
  }
}

Query.prototype.load = function(callbacks) {
  var self = this;

  $.ajax({
    url: '/queries/' + this.id + '.json',
    type: 'GET',
    dataType: 'json',
    success: function(data) {
      if (data.results) {
        if (callbacks.success) callbacks.success(data);
      } else {
        if (callbacks.error) callbacks.error(data.error);
      }
    },
    error: function() {
      if (callbacks.error) callbacks.error("Failed to load results");
    }
  });
}

function QueryEditor(form, options) {
  this._monitorQueryId = null;
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
    if ((e.keyCode === 13 && (e.ctrlKey || e.metaKey)) || (e.metaKey && e.altKey && e.keyCode === 82)) {
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
  if (this._monitorQueryId !== null) {
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
