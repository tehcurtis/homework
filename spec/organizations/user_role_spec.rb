RSpec.describe UserRole do
  it 'takes a user' do
    user = double(:user)
    user_role = UserRole.new(user: user)

    expect(user_role.user).to eq user
  end

  it 'takes a role' do
    role = double(:role)
    user_role = UserRole.new(role: role)

    expect(user_role.role).to eq role
  end

  it 'takes an org' do
    org = double(:org)
    user_role = UserRole.new(org: org)

    expect(user_role.org).to eq org
  end
end
