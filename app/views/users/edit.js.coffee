
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/user', locals: {user: @user, path: users_edit_path}
) %>")
$("#myModal").modal()

