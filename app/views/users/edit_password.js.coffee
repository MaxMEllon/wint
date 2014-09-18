
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/user_password', locals: {user: @user, path: users_edit_password_path}
) %>")
$("#myModal").modal()

