RSpec.describe User do
  describe '#has_admin_access?' do
    context 'when the org is a root org' do
      it 'is true if the user has admin level access' do
        user = User.new
        org = RootOrg.new
        role = Role.new('admin')

        user.add_role_and_org(role, org)

        expect(user.has_admin_access?(org)).to eq true
      end

      it 'is false if the user does not have admin access' do
        user = User.new
        org = RootOrg.new

        expect(user.has_admin_access?(org)).to eq false
      end
    end

    context 'when the org is a mid-level org' do
      it 'is true if the user has admin level access to the org' do
        user = User.new
        org = Org.new
        role = Role.new('admin')

        user.add_role_and_org(role, org)

        expect(user.has_admin_access?(org)).to eq true
      end

      it "is is true if the user has admin level access to the org's root org" do
        user = User.new
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('admin')

        user.add_role_and_org(role, root_org)

        expect(user.has_admin_access?(org)).to eq true
      end

      it 'is false if the user only has user access to the org' do
        user = User.new
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('user')

        user.add_role_and_org(role, org)

        expect(user.has_admin_access?(org)).to eq false
      end

      it 'is false if the user only has user access to the root org' do
        user = User.new
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('user')

        user.add_role_and_org(role, org)

        expect(user.has_admin_access?(org)).to eq false
      end
    end

    context 'when the org is a child org' do
      it 'is true if the user has admin access to the child org' do
        user = User.new
        role = Role.new('admin')
        child_org = ChildOrg.new

        user.add_role_and_org(role, child_org)

        expect(user.has_admin_access?(child_org)).to eq true
      end

      it "is true if the user has admin access to the child org's parent org" do
        user = User.new
        role = Role.new('admin')
        parent_org = Org.new
        child_org = ChildOrg.new(parent_org)

        user.add_role_and_org(role, parent_org)

        expect(user.has_admin_access?(child_org)).to eq true
      end

      it 'is true if the user has admin access to the top-level root org' do
        user = User.new
        role = Role.new('admin')
        root_org = RootOrg.new
        parent_org = Org.new(root_org: root_org)
        child_org = ChildOrg.new(parent_org)

        user.add_role_and_org(role, root_org)

        expect(user.has_admin_access?(child_org)).to eq true
      end

      it 'is false if the user has admin access to the top-level root org, but has a denied role for the given child org' do
        user = User.new
        role = Role.new('admin')
        denied_role = Role.new('denied')
        root_org = RootOrg.new
        parent_org = Org.new(root_org: root_org)
        child_org = ChildOrg.new(parent_org)

        user.add_role_and_org(role, root_org)
        user.add_role_and_org(denied_role, child_org)

        expect(user.has_admin_access?(child_org)).to eq false
      end
    end
  end
end
