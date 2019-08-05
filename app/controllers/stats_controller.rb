class StatsController < ApplicationController
  def show
    @stat = Stat.fast_find_by(stat_params)
    if !@stat.blank?
      json_response(@stat)
    else
      json_response(nil, :unprocessable_entity, :invalid_input)
    end
  end

  def stat_params
    params.permit(:thermostat_id, :sensor_type)
  end
end
