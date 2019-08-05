class ReadingsController < ApplicationController
  def create
    @reading = Reading.new(reading_params)
    @response = @reading.save_it
    if !@response.blank?
      json_response(@response, :created, :successful)
    else
      json_response(nil, :unprocessable_entity, :invalid_input)
    end
  end

  def show
    @reading = Reading.find_by_tracking_number(reading_params)
    if !@reading.blank?
      json_response(@reading)
    else
      json_response(nil, :unprocessable_entity, :invalid_input)
    end
  end

  private

  def reading_params
    params.permit(:thermostat_id, :temperature, :humidity, :battery_charge, :tracking_number, :household_token)
  end
end
