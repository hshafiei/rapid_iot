class ReadingsController < ApplicationController
  def create
    @reading = Reading.new(reading_params)
    @reading.fast_save
  end

  def show
    @reading = Reading.find_by_tracking_number(params)
    if @reading
      json_response(@reading)
    else

    end
  end

  private

  def reading_params
    params.permit(:thermostat_id, :temperature, :humidity, :battery_charge, :tracking_number, :household_token)
  end
end
