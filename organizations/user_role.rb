class UserRole
  attr_reader :role, :user, :org

  def initialize(opts={})
    @user = opts[:user]
    @role = opts[:role]
    @org = opts[:org]
  end


end
