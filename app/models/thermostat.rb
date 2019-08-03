
# == Schema Information
#
# Table name: households
#
#  id                   :integer          not null, primary key
#  household_token      :text
#  location             :text
#  created_at           :datetime
#  updated_at           :datetime


class Thermostat < ApplicationRecord
  has_many :readings
  has_many :stats



end
