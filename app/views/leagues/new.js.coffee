
$("#myModal").html("<%= escape_javascript(
  render partial: 'shared/modal/league', locals: {league: @league, path: leagues_new_path}
) %>")
$("#myModal").modal()

