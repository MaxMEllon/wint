feature 'edit league', state: :league_list do
  given!(:league) { League.create attributes_for :league }

  background do
    visit leagues_path
    click_button '編集'
    wait_for_action(1.0)
  end

  context 'when name updated' do
    background do
      fill_in 'league[name]', with: 'fooリーグ'
      click_button '更新'
      wait_for_action
    end

    scenario 'change name', js: true do
      expect(page).to have_content 'fooリーグ'
    end
  end

  context 'when rules updated' do
    background do
      fill_in 'rule[change]', with: 10
      fill_in 'rule[take]', with: 100
      fill_in 'rule[try]', with: 1000
      click_button '更新'
      wait_for_action
    end

    scenario 'change rules', js: true do
      expect(page).to have_content '10-100-1000'
    end
  end
end

