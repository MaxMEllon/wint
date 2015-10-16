feature 'register league', state: :league_list do
  background do
    click_button '登録'
    wait_for_action
  end

  context 'when nothing inputted' do
    pending
    # background do
    #   click_button '作成'
    #   wait_for_action
    # end

    # scenario '失敗する' do
    #   expect(page).to have_content '入力してください'
    # end
  end

  context 'when all inputted' do
    given(:league) { attributes_for :feature_league }

    background do
      fill_in 'league[name]',        with: league[:name]
      fill_in 'league[limit_score]', with: league[:limit_score]
      fill_in 'league[start_at]',    with: league[:start_at]
      fill_in 'league[end_at]',      with: league[:end_at]
      attach_file 'file[stock]',  league[:stock]
      attach_file 'file[exec]',   league[:exec]
      attach_file 'file[header]', league[:header]
      attach_file 'file[card]',   league[:card]
      fill_in 'rule[change]', with: league[:change]
      fill_in 'rule[take]',   with: league[:take]
      fill_in 'rule[try]',    with: league[:try]
      click_button '作成'
      wait_for_action
    end

    scenario 'display the new league in the list', js: true do
      expect(page).to have_content league[:name]
    end
  end
end

