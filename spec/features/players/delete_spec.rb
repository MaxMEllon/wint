feature 'プレイヤ削除' do
  given(:user) { create :admin }
  given(:league) { build :league }
  given(:player) { build :player }

  background do
    login user
    create_league(league)
    create_player(player)
    visit players_path
  end

  context 'プレイヤが有効な場合', js: true do
    background do
      click_button '無効化'
    end

    scenario 'プレイヤを削除できる' do
      expect(page).to have_button '有効化'
    end
  end

  context 'プレイヤが無効な場合', js: true do
    background do
      Player.first.update(is_active: false)
      reload_page
      click_button '有効化'
    end

    scenario 'プレイヤを有効化できる' do
      expect(page).to have_button '無効化'
    end
  end
end

