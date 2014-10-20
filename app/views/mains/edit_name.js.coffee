
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/player_name', locals: {player: @player, path: main_edit_name_path}
) %>")
$("#myModal").modal()

