class ReadingsController < ApplicationController
  def create
    @reading = Reading.new(reading_params)
    @reading.fast_store
  end

  def show
    @reading = Reading.find_by_tracking_number(params)
    json_response(@reading)
  end

  private

  def reading_params
    params.permit(:thermostat_id, :temperature, :humidity, :battery_charge, :tracking_number, :household_token)
  end
end
