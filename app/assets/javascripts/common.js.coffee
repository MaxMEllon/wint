
@datetimepicker = ->
  $(".datepicker").datetimepicker({
    format: 'YYYY-MM-DD HH:mm:ss',
    useSeconds: true
  })

$(document).ready ->
  $(".datatable").dataTable({
    autoWidth: false,
    lengthMenu: [5, 10, 20, 50],
    pageLength: 20
  })

