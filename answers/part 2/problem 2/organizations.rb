base = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(base) unless $LOAD_PATH.include?(base)

%w{
organizations/user
organizations/role
organizations/user_role
organizations/root_org
organizations/org
organizations/child_org
organizations/access_manager
}.each do |str|
  require str
end
