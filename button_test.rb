  it "has 'S’abonner à Jam Trends' and 'Se Connecter' buttons", js:true do
    expect(page).to have_content('Pour accéder à ces données')
    click_on('S’abonner à Jam Trends')
    expect(page).to have_current_path(root_path)
    visit(questions_path)
    click_on('Se Connecter')
    expect(page).to have_current_path(new_company_user_session_path)
  end