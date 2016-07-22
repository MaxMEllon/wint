feature 'プレイヤ削除' do
  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    player
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
      player.update(is_active: false)
      reload_page
      click_button '有効化'
    end

    scenario 'プレイヤを有効化できる' do
      expect(page).to have_button '無効化'
    end
  end
end

