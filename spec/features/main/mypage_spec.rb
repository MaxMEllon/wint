feature 'Access check from mypage', state: :main_mypage do
  context 'in submission button' do
    context 'within the contest term' do
      scenario 'exist submission button', js: true do
        expect(page).to have_content '戦略提出'
      end

      feature 'when the submission button cliked' do
        background do
          click_button '戦略提出'
          wait_for_action
        end

        scenario 'display submission form of strategy', js: true do
          expect(page).to have_content '戦略提出'
        end
      end
    end

    context 'out of the contest term' do
      background do
        allow_any_instance_of(League).to receive(:open?).and_return(false)
        visit main_set_player_path(pid: player.id)
      end

      scenario 'not exist submission button', js: true do
        expect(page).to have_no_content '戦略提出'
      end
    end
  end

  context 'in submission log' do
    background do
      @league = League.find(1)
      Submit.create attributes_for :submit
    end

    context 'when the analysis of browsing is permitted' do
      background do
        @league.update(is_analy: true)
        visit main_mypage_path
      end

      scenario 'exist link of strategy detail page', js: true do
        expect(page).to have_link '001'
      end

      feature 'when the link clicked' do
        background do
          click_link '001'
          wait_for_action
        end

        scenario 'move to strategy detail page', js: true do
          expect(page).to have_content '戦略詳細'
        end
      end
    end

    context 'when the analysis of browsing is not permitted' do
      background do
        @league.update(is_analy: false)
        visit main_mypage_path
      end

      scenario 'have submission number', js: true do
        expect(page).to have_content '001'
      end

      scenario 'have no link of strategy detail page', js: true do
        expect(page).to have_no_link '001'
      end
    end
  end
end

