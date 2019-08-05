require 'rails_helper'

RSpec.describe Stat, type: :model do
  it { should validate_presence_of(:thermostat_id) }
  it { should validate_presence_of(:sensor_type) }
end
