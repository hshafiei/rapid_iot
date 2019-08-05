
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
  after_create :fast_save

  # According to https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-jobs-input-small-and-simple
  # it is not the best practice to pass complex ruby object to sidekiq. We here use Redis as a temporary data store
  # Redis is in-memory so it is fast enough.

  def save_it
    if validate_presence && validate_existence
      fill_tracking_number
      fast_create
      extract_stat
      return prepare_response
    end
  end

  # Updates the stats table
  def extract_stat
    Thermostat.notfiy_new_reading(self)
  end

  # Accepts tracking_number and thermostat_id and fast_find it
  def self.find_by_tracking_number(args)
    reading = fast_find(args)
    reading['data'] if reading
  end

  # Gets the incremented last tracking_number
  def fill_tracking_number
    self.tracking_number = HouseHold.inc_tracking_number(token: self.household_token)
  end

  # As we are trying to make responses as fast as possible we dont have th ID instantly
  # we can use uuid but the challange requires to use the following keys
  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:thermostat_id]}_#{args[:tracking_number]}"
  end

  def self.find_args(args)
    {tracking_number: args[:tracking_number], thermostat_id: args[:thermostat_id]}
  end

  def self.find_in_db(args)
    where(find_args(args)).first rescue false
  end

  # Prepares and returns the response
  def prepare_response
    arg = klass.find_args(self)
    hash = klass.fast_find(arg)
    return RedisCrud.data_extract(hash)
  end

  # Returns the thermostat associated with this reading
  def the_thermostat
    Thermostat.fast_find({id: thermostat_id})
  end

  # Returns the household associated with this reading
  def the_household
    HouseHold.fast_find({token: household_token})
  end

  # For now we are just going to implement validation for our fast CRUD
  # this must be improved later
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
