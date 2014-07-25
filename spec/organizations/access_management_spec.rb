RSpec.describe AccessManager do
  describe '#has_admin_access?' do
    context 'when the org is a root org' do
      let(:user) { User.new }

      it 'is true if the user has admin level access' do
        org = RootOrg.new
        role = Role.new('admin')
        user.add_role_and_org(role, org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq true
      end

      it 'is false if the user does not have admin access' do
        org = RootOrg.new

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq false
      end
    end

    context 'when the org is a mid-level org' do
      let(:user) { User.new }

      it 'is true if the user has admin level access to the org' do
        org = Org.new
        role = Role.new('admin')
        user.add_role_and_org(role, org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq true
      end

      it "is is true if the user has admin level access to the org's root org" do
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('admin')
        user.add_role_and_org(role, root_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq true
      end

      it 'is false if the user only has user access to the org' do
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('user')
        user.add_role_and_org(role, org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq false
      end

      it 'is false if the user only has user access to the root org' do
        root_org = RootOrg.new
        org = Org.new(root_org: root_org)
        role = Role.new('user')
        user.add_role_and_org(role, org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(org)).to eq false
      end
    end

    context 'when the org is a child org' do
      let(:user) { User.new }
      let(:admin_role) { Role.new('admin') }

      it 'is true if the user has admin access to the child org' do
        child_org = ChildOrg.new
        user.add_role_and_org(admin_role, child_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(child_org)).to eq true
      end

      it "is true if the user has admin access to the child org's parent org" do
        parent_org = Org.new
        child_org = ChildOrg.new(parent_org)
        user.add_role_and_org(admin_role, parent_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(child_org)).to eq true
      end

      it 'is true if the user has admin access to the top-level root org' do
        root_org = RootOrg.new
        parent_org = Org.new(root_org: root_org)
        child_org = ChildOrg.new(parent_org)
        user.add_role_and_org(admin_role, root_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(child_org)).to eq true
      end

      it 'is false if the user has admin access to the top-level root org, but has a denied role for the given child org' do
        denied_role = Role.new('denied')
        root_org = RootOrg.new
        parent_org = Org.new(root_org: root_org)
        child_org = ChildOrg.new(parent_org)
        user.add_role_and_org(admin_role, root_org)
        user.add_role_and_org(denied_role, child_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(child_org)).to eq false
      end

      it 'is false if the user has admin access to the top-level root org, but only has user access to the given org' do
        user_role = Role.new('user')
        root_org = RootOrg.new
        parent_org = Org.new(root_org: root_org)
        child_org = ChildOrg.new(parent_org)
        user.add_role_and_org(admin_role, root_org)
        user.add_role_and_org(user_role, child_org)

        access_manager = AccessManager.new(user)

        expect(access_manager.has_admin_access?(child_org)).to eq false
      end
    end
  end

  describe '#has_user_access?' do
    it 'is true if the user has user-level access to the given org' do
      user_role = Role.new('user')
      user = User.new
      root_org = RootOrg.new
      user.add_role_and_org(user_role, root_org)

      access_manager = AccessManager.new(user)

      expect(access_manager.has_user_access?(root_org)).to be true
    end
  end
end
