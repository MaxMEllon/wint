
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/user_many', locals: {path: users_new_many_path}
) %>")
$("#myModal").modal()

