class AccessManager
  attr_reader :user, :org

  def initialize(user, org)
    @user = user
    @org = org
  end

  def denied_orgs
    user.roles_and_orgs['denied']
  end

  def has_admin_access?(org)
    accessible_orgs = user.roles_and_orgs['admin']
    user_accessible_orgs = user.roles_and_orgs['user']

    return false if accessible_orgs.nil?
    return false if denied_orgs.include?(org)
    return false if user_accessible_orgs.include?(org)

    if org.is_a?(RootOrg)
      accessible_orgs.include?(org)
    elsif org.is_a?(Org)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.root_org)
    elsif org.is_a?(ChildOrg)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.parent_org) || accessible_orgs.include?(org.parent_org.root_org)
    end
  end

  def has_user_access?(org)
    accessible_orgs = user.roles_and_orgs['user']
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
