feature '戦略ファイルの提出' do
  PATH = "#{Rails.root}/spec/factories/files/PokerOpe"

  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    player
    visit main_select_path
    visit main_set_player_path(pid: player.id) # or click_link player.name
    click_button '戦略提出'

    fill_in 'submit[data_dir]', with: File.read(path)
    fill_in 'submit[comment]', with: 'てすと'
    click_button '提出'
  end

  context '正しい戦略を提出した場合' do
    given(:path) { PATH + '/success.c' }

    scenario '成功と表示される', js: true do
      expect(page).to have_content '成功'
    end
  end

  context 'コンパイルエラーとなる戦略を提出した場合' do
    given(:path) { PATH + '/compile_error.c' }

    scenario 'コンパイルエラーと表示される', js: true do
      expect(page).to have_content 'コンパイルエラー'
    end
  end

  context '実行時エラーとなる戦略を提出した場合' do
    given(:path) { PATH + '/execute_error.c' }

    scenario '実行時エラーと表示される', js: true do
      expect(page).to have_content '実行時エラー'
    end
  end

  context '危険なコードを含んだ戦略を提出した場合' do
    given(:path) { PATH + '/syntax_error.c' }

    scenario '危険なコードと表示される', js: true do
      expect(page).to have_content '危険なコード'
    end
  end

  context '時間超過となる戦略を提出した場合' do
    given(:path) { PATH + '/timeout_error.c' }

    background do
      stub_const('Submit::TIME_LIMIT', 1)
    end

    scenario '時間超過と表示される', js: true do
      expect(page).to have_content '時間超過'
    end
  end
end

