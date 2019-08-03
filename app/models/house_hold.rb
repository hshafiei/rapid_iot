
# == Schema Information
#
# Table name: households
#
#  id                   :integer          not null, primary key
#  token                :integer
#  tracking_number      :integer
#  created_at           :datetime
#  updated_at           :datetime

class HouseHold < ApplicationRecord

  # This hook ensures that after creation houshold is stored in redis
  after_create :add_to_store

  # It returns the last tracking_number of a given household. It first looks redis for the answer and then tries DB to speed up
  def self.last_tracking_number(args)
    in_store(args)? in_store(args) : get_store_db(args).tracking_number.to_i
  end


  # Increments the last tracking_number of a household in DB
  def self.inc_tracking_number_db(token)
    if from_db(token)
      household = from_db(token)
      household.inc_and_save
    end
  end

  # Increments the last tracking_number of a household in redis
  # This method is spreated from inc_tracking_number_db since we dont want to access DB per request, this keeps tarck of last tracking_number
  # until eventaully it stores in DB

  def self.inc_tracking_number_store(args)
    tracking_number = retrieve_from_redis(args)
    store_in_redis(key(args), tracking_number + 1) if tracking_number
  end



  def self.key(args)
    "household_#{args[:token]}"
  end

  def serial_data
    self.tracking_number
  end

  def add_to_store
    klass = self.class
    klass.store_in_redis(klass.key(self.token), self.tracking_number)
  end

  def inc_and_save
    self.tracking_number += 1
    self.save
  end

end


# # Checks if redis has the last tracking_number
# def self.in_store(token)
#   retrieve_from_redis(token)
# end
#
# # Gets reading from DB and store it in redis to speedup feature requests
# def self.get_store_db(token)
#   houshold = from_db(token)
#   klass = houshold.class # Since we are dealing with class method
#   klass.store_in_redis(klass.key(houshold.token), houshold.tracking_number) if houshold
#   return houshold
# end
#
# # Returns the houshold with given token
# def self.from_db(token)
#   where(token: token).first rescue false
# end
