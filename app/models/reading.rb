
# == Schema Information
#
# Table name: readings
#
#  id                   :integer          not null, primary key
#  thermostat_id        :integer
#  tracking_number      :integer
#  temperature          :float
#  humidity             :float
#  battery_charge       :float
#  created_at           :datetime
#  updated_at           :datetime
#  household_token      :text
#  uuid                 :varchar

class Reading < ApplicationRecord

  belongs_to :thermostat
  after_create :save_in_redis

  # According to https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-jobs-input-small-and-simple
  # it is not the best practice to pass complex ruby object to sidekiq. We here use Redis as a temporary data store
  # Redis is in-memory so it is fast enough.

  def fast_save
    fill_tracking_number
    fast_create
  end

  def self.find_by_tracking_number(args)
    fast_find(args)
  end

  # Gets the last tracking_number and increments it
  def fill_tracking_number
    self.tracking_number = HouseHold.inc_tracking_number(token: self.household_token)
  end

  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:household_token]}_#{args[:tracking_number]}"
  end

  def self.find_in_db(args)
    where(household_token: args[:household_token], tracking_number: args[:tracking_number]).first rescue false
  end



  # Finds readings by tracking_number and household_token the params format is {household_token: 'X', tracking_number: 'Y' }
  # It checks redis first, if it cannot find then tries DB




end
