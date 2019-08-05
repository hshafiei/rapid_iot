
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
  validates_presence_of :thermostat_id, :temperature, :humidity, :battery_charge
  after_create :save_in_redis

  # According to https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-jobs-input-small-and-simple
  # it is not the best practice to pass complex ruby object to sidekiq. We here use Redis as a temporary data store
  # Redis is in-memory so it is fast enough.

  def fast_save
    if validate_presence && validate_existence
      fill_tracking_number
      fast_create
      extract_stat
      return fast_response
    end
  end

  def extract_stat
    Thermostat.notfiy_new_reading(self)
  end

  def self.find_by_tracking_number(args)
    reading = fast_find(args)
    reading['data'] if reading
  end

  # Gets the last tracking_number and increments it
  def fill_tracking_number
    self.tracking_number = HouseHold.inc_tracking_number(token: self.household_token)
  end

  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:thermostat_id]}_#{args[:tracking_number]}"
  end

  def self.find_args(args)
    {tracking_number: args[:tracking_number], thermostat_id: args[:thermostat_id]}
  end

  def self.find_in_db(args)
    where(find_args(args)).first rescue false
  end

  def fast_response
    arg = klass.find_args(self)
    hash = klass.fast_find(arg)
    return RedisCrud.data_extract(hash)
  end

  def the_thermostat
    Thermostat.fast_find({id: thermostat_id})
  end

  def the_household
    HouseHold.fast_find({token: household_token})
  end

  def validate_presence
    thermostat_id.present? && household_token.present? && temperature.present? && humidity.present? && battery_charge.present?
  end

  def validate_existence
    thermostat_exists? && household_exists?
  end

  def thermostat_exists?
    the_thermostat.present? ? true : false
  end

  def household_exists?
    the_household.present? ? true : false
  end

  def klass
    self.class
  end


end
