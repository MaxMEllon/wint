module ActionHelper
  def create_strategies(league)
    5.times do |i|
      index = i + 1
      player = create("player#{index}".to_sym, league_id: league.id)
      submit = create(:submit, player_id: player.id, id: index)
      create(:strategy, "type#{index}".to_sym, submit_id: submit.id)
    end

    `rm -rf #{Rails.root}/tmp/data/001`
    `cp -r #{Rails.root}/spec/factories/files/001 #{Rails.root}/tmp/data/001`
  end

  def reload_page
    visit current_path
  end
end

