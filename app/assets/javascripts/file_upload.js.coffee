# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#record_file_upload').attr('name','record[file_upload]')
  console.log "called file_upload"
  $('#new_record').fileupload
    dataType: 'script'
    add: (e, data) ->
      console.log "inside second call"
      
      types = /(\.|\/)(xls|xlt|xla|xlsx|xlsm|xltx|xltm|xlsb|xlam|csv|tsv|docx|doc|dotx|docm|dotm|pptx|ppt|potx|pot|ppsx|pps|pptm|potm|ppsm|ppam|mp3|mp4|jpg|png|gif|pdf|3gpp|txt)$/i
      
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.context = $(tmpl("template-upload", file))
        $('#new_record').append(data.context)
        $('.actions input[type="submit"]').click (e) ->
          data.submit()
          e.preventDefault()           
      else
        alert("#{file.name} is not a gif, jpg or png image file")
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
    done: (e, data) ->
      $('.actions input[type="submit"]').off('click')

