feature 'マイページからのアクセス', js: true do
  shared_context 'リーグ選択ページを表示している', state: :main_request do
    given(:player) { create :player }
    background do
      create :league
      sign_in create :student
    end
  end

  context '大会期間外の場合', state: :main_request do
    background do
      allow_any_instance_of(League).to receive(:open?).and_return(false)
      visit main_set_player_path(pid: player.id)
      wait_for_action
    end

    scenario '戦略提出ボタンが存在しない' do
      expect(page).to have_no_content '戦略提出'
    end
  end

  context '大会期間内の場合', state: :main_request do
    background do
      allow_any_instance_of(League).to receive(:open?).and_return(true)
      visit main_set_player_path(pid: player.id)
      wait_for_action
    end

    scenario '戦略提出ボタンが存在する' do
      expect(page).to have_content '戦略提出'
    end

    feature '戦略提出ボタンを押す' do
      background do
        click_button '戦略提出'
        wait_for_action
      end

      scenario '戦略提出フォームが表示される' do
        within('div#myModal') do
          expect(page).to have_content '戦略提出'
        end
      end
    end
  end
end

