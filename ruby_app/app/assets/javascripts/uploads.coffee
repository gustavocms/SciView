$ ->
  $('.directUpload').find("input:file").each (i, elem) ->
    fileInput = $(elem)

    form         = $(fileInput.parents('form:first'))
    submitButton = form.find('input[type="submit"]')
    progressBar  = $("<div class='bar'></div>")
    status       = $("<div class='status'></div")
    barContainer = $("<div class='progress'></div>").append(progressBar).append(status)
    host         = fileInput.data('s3Host')
    console.log(host)
    fileInput.after(barContainer)
    fileInput.fileupload({
      fileInput:        fileInput
      url:              fileInput.data('s3Url')
      type:             'POST'
      autoUpload:       true
      formData:         fileInput.data('s3Fields')
      paramName:        'file'
      dataType:         'XML'
      replaceFileInput: false

      progressAll: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css('width', progress + '%')
      start: (e) ->
        submitButton.prop('disabled', true)
        progressBar
          .css('background', 'green')
          .css('display', 'block')
          .css('width', '0%')
        status.text('Uploading...')
      done: (e, data) ->
        submitButton.prop('disabled', false)
        status.text("File uploaded. Click 'save changes' to continue processing.")
        key = $(data.jqXHR.responseXML).find("Key").text()
        input = $('<input />', { type: 'hidden', name: fileInput.attr('name'), value: key })
        fileInput.hide()
        form.append(input)
      fail: (e, data) ->
        submitButton.prop('disabled', false)
        progressBar
          .css('background', 'red')
          .text('failed')

    })

