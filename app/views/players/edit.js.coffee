
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/player', locals: {player: @player, path: players_edit_path}
) %>")
$("#myModal").modal()

