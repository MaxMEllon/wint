
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/code', locals: {submit: @submit}
) %>")
$("#myModal").modal()

