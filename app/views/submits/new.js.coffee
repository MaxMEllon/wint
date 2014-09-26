
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/submit', locals: {submit: @submit, path: submits_new_path}
) %>")
$("#myModal").modal()

