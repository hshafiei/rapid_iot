
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
  after_create :save_in_redis

  # It returns the last tracking_number of a given household. It first looks redis for the answer and then tries DB to speed up
  def self.last_tracking_number(args)
    household = fast_find(args)
    extract_tracking_number(household) if household
  end


  # Increments the last tracking_number of a household in redis
  # This method is spreated from inc_tracking_number_db since we dont want to access DB per request, this keeps tarck of last tracking_number
  # until eventaully it stores in DB

  def self.inc_tracking_number(args)
    hash = increment(args)
    extract_tracking_number(hash) if hash
  end

  def self.increment(args)
    household = fast_find(args)
    fast_update(args, update_args(household)) if household
    return fast_find(args)
  end

  def self.update_args(household)
    { 'tracking_number' => extract_tracking_number(household) + 1}
  end

  def self.extract_tracking_number(args)
    args['data']['tracking_number']
  end

  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:token]}"
  end


  def self.find_in_db(args)
    where(token: args[:token]).first rescue false
  end

  def key
    {token: self.token}
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
