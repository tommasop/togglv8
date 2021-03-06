describe 'Users' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @user = @toggl.me(all=true)
  end

  it 'returns /me' do
    expect(@user).to_not be_nil
    expect(@user['id']).to eq 1820939
    expect(@user['fullname']).to eq 'togglv8'
    expect(@user['image_url']).to eq 'https://assets.toggl.com/avatars/a5d106126b6bed8df283e708af0828ee.png'
    expect(@user['timezone']).to eq 'Etc/UTC'
    expect(@user['workspaces'].length).to eq 1
    expect(@user['workspaces'].first['name']).to eq "togglv8's workspace"
  end

  it 'returns /my_clients' do
    my_clients = @toggl.my_clients(@user)
    expect(my_clients).to be_empty
  end

  it 'returns /my_projects' do
    my_projects = @toggl.my_projects(@user)
    expect(my_projects).to be_empty
  end

  it 'returns /my_tags' do
    my_tags = @toggl.my_tags(@user)
    expect(my_tags).to be_empty
  end

  it 'returns /my_time_entries' do
    my_time_entries = @toggl.my_time_entries(@user)
    expect(my_time_entries).to be_empty
  end

  it 'returns /my_workspaces' do
    my_workspaces = @toggl.my_workspaces(@user)
    expect(my_workspaces.length).to eq 1
  end

  context 'new user' do
    it 'creates a new user' do
      now = Time.now.to_i
      user_info = {
        'email' => "test-#{now}@mailinator.com",
        'timezone' => 'Etc/UTC'
      }
      user_password = { 'password' => "password-#{now}" }

      new_user = @toggl.create_user(user_info.merge(user_password))
      expect(new_user).to include(user_info)
    end
  end
end