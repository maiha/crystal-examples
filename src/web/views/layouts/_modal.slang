#modal.modal.fade aria-hidden="true" aria-labelledby="exampleModalLabel" role="dialog" tabindex="-1" 
  .modal-dialog role="document" 
    .modal-content
      .modal-header
      .modal-body
      .modal-footer

javascript:
  $('#modal').on('show.bs.modal', function (event) {
    var caller = $(event.relatedTarget)
    var modal  = $(this)
    var url    = caller.attr('href')

    modal.find('.modal-header').text(caller.attr('title'))
    modal.find('.modal-footer').text(url)
    if (url) {
      $.ajax({
        url: url
      }).done(function(data, status, xhr) {
        var ct = xhr.getResponseHeader("content-type") || "";
        if (ct.indexOf('html') > -1) {
          modal.find('.modal-body').html(data);
        } else {
          modal.find('.modal-body').html("<pre>" + data + "</pre>");
        }
      }).fail(function(xhr, textStatus, err) {
        modal.find('.modal-header').text(xhr.status);
        modal.find('.modal-body').text(err.message || xhr.responseText);
      });
    } else {
      modal.find('.modal-body').text("URL not found");
    }
  });
