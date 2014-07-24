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

  def has_admin_access?(org)
    accessible_orgs = roles_and_orgs['admin']
    denied_orgs = roles_and_orgs['denied']
    return false if accessible_orgs.nil?
    return false if denied_orgs && denied_orgs.include?(org)

    if org.is_a?(RootOrg)
      accessible_orgs.include?(org)
    elsif org.is_a?(Org)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.root_org)
    elsif org.is_a?(ChildOrg)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.parent_org) || accessible_orgs.include?(org.parent_org.root_org)
    end
  end
end
