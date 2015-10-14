shared_context 'when analysis page displayed', state: :analysis_list do
  background do
    sign_in create :admin
    visit analysis_list_path
  end
end

