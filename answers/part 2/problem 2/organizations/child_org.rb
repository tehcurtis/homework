class ChildOrg
  attr_reader :parent_org

  def initialize(parent_org=nil)
    @parent_org = parent_org
  end
end
