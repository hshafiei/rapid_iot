
require 'rails_helper'

RSpec.describe Thermostat, type: :model do
  it { should validate_presence_of(:house_hold_id) }
end
