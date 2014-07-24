require 'organizations/root_org'

RSpec.describe RootOrg do
  it 'has organizations' do
    expect(RootOrg.new.organizations).to eq []
  end

end
