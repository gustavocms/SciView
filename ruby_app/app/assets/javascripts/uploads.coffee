$ ->
  $('.directUpload').find("input:file").each (i, elem) ->
    fileInput = $(elem)
    console.log(fileInput.data('s3Url'))

    form         = $(fileInput.parents('form:first'))
    submitButton = form.find('input[type="submit"]')
    progressBar  = $("<div class='bar'></div>")
    barContainer = $("<div class='progress'></div>").append(progressBar)
    fileInput.after(barContainer)
    options = {
      fileInput: fileInput
      url:       fileInput.data('s3Url')
      type:      'POST'
      autoUpload: true
      formData: fileInput.data('s3Fields') 
      paramName: 'file'
      dataType: 'XML'
      replaceFileInput: false
    }
    console.log(options)
    fileInput.fileupload(options)

