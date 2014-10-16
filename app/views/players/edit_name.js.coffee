
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/player_name', locals: {player: @player, path: players_edit_path(pid: @player.id)}
) %>")
$("#myModal").modal()

