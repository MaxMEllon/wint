
$(document).ready ->
  $(".datatable").dataTable({
    autoWidth: false,
    lengthMenu: [5, 10, 20, 50],
    pageLength: 10
  })

