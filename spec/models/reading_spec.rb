require 'rails_helper'

RSpec.describe Reading, type: :model do
  it { should validate_presence_of(:thermostat_id) }
  it { should validate_presence_of(:temperature) }
  it { should validate_presence_of(:humidity) }
  it { should validate_presence_of(:battery_charge) }
end
