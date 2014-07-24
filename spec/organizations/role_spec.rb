require 'organizations/role'

RSpec.describe Role do
  it 'has a name' do
    role = Role.new('admin')

    expect(role.name).to eq 'admin'
  end
end
