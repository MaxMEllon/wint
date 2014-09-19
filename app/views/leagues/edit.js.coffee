
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/league', locals: {league: @league, path: leagues_edit_path}
) %>")
$("#myModal").modal()

