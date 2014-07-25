class AccessManager
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def has_admin_access?(org)
    accessible_orgs = user.roles_and_orgs['admin']

    return false if fails_admin_prerequisites?(org)

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

    return false if fails_user_prerequisites?(org)

    if org.is_a?(RootOrg)
      accessible_orgs.include?(org)
    elsif org.is_a?(Org)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.root_org)
    elsif org.is_a?(ChildOrg)
      accessible_orgs.include?(org) || accessible_orgs.include?(org.parent_org) || accessible_orgs.include?(org.parent_org.root_org)
    end
  end

  private

  def fails_admin_prerequisites?(org)
    accessible_admin_orgs == [] || denied_orgs.include?(org) || accessible_user_orgs.include?(org)
  end

  def fails_user_prerequisites?(org)
    accessible_orgs = user.roles_and_orgs['user']
    accessible_orgs == [] || denied_orgs.include?(org)
  end

  def denied_orgs
    user.roles_and_orgs['denied']
  end

  def accessible_user_orgs
    user.roles_and_orgs['user']
  end

  def accessible_admin_orgs
    user.roles_and_orgs['admin']
  end
end
