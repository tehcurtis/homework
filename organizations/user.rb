class User
  attr_accessor :roles_and_orgs

  def initialize
    # role: [orgs], role: [orgs]
    @roles_and_orgs = Hash.new {|hash, key| hash[key] = []}
  end

  def add_role_and_org(role, org)
    if roles_and_orgs.has_key?(role.name.downcase)
      roles_and_orgs << org
    else
      roles_and_orgs[role.name] << org
    end
  end
end
