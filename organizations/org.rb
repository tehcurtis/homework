class Org
  attr_reader :root_org

  def initialize(opts={})
    @root_org = opts[:root_org]
  end
end
