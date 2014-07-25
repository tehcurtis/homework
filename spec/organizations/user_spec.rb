RSpec.describe User do
  it 'defaults roles_and_orgs to a hash' do
    expect(User.new.roles_and_orgs).to eq({})
  end

  describe '#add_role_and_org' do
    it 'adds the given role and org to the hash' do
      user = User.new
      role = Role.new('admin')
      org = Org.new

      user.add_role_and_org(role, org)

      expect(user.roles_and_orgs).to include({'admin' => [org]})
    end
  end
end
