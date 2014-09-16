
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/user', locals: {user: @user, path: users_new_path}
) %>")
$("#myModal").modal()

