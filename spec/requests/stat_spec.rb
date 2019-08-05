require 'rails_helper'

describe 'GET /stats' do
  let(:stats) { create_list(:stat, 10) }
  let(:thermostat_id) { stats.first.thermostat.id }
  let(:sensor_type) { stats.first.sensor_type }

  context 'when the request is valid' do
    before { get "/stats?sensor_type=#{sensor_type}&thermostat_id=#{thermostat_id}", as: :json}
    it 'finds the stat' do
      expect(json['data']).not_to eql(nil)
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  context 'when the request is invalid' do
    before { get '/stats?', as: :json}

    it 'returns status code 422' do
      expect(response).to have_http_status(422)
    end

    it 'returns a validation failure message' do
      expect(response.body)
      .to match(/{\"data\":null,\"message\":\"Invalid input is provided\"}/)
    end
  end
end
