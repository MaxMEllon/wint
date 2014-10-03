
@datetimepicker = ->
  $(".datepicker").datetimepicker({
    format: 'YYYY.MM.DD HH:mm',
    useSeconds: true
  })

$(document).ready ->
  $(".datatable-desc").dataTable({
    order: [0, "desc"],
    autoWidth: false,
    lengthMenu: [5, 10, 20, 50],
    pageLength: 20
  })
  $(".datatable").dataTable({
    autoWidth: false,
    lengthMenu: [5, 10, 20, 50],
    pageLength: 20
  })

