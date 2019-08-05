require 'rails_helper'

describe 'POST /readings' do
  context 'when the request is valid reading' do
    before { post '/readings', params: FactoryBot.create(:reading), as: :json}
    it 'creates a reading' do
      expect(json['data']).not_to eql(nil)
    end
    it 'returns status code 201' do
      expect(response).to have_http_status(201)
    end
  end

  context 'when the request is invalid' do
    before { post '/readings', params: {}, as: :json}

    it 'returns status code 422' do
      expect(response).to have_http_status(422)
    end

    it 'returns a validation failure message' do
      expect(response.body)
      .to match(/{\"data\":null,\"message\":\"Invalid input is provided\"}/)
    end
  end
end

describe 'GET /readings' do
  let(:readings) { create_list(:reading, 10) }
  let(:tracking_number) { readings.first.tracking_number }
  let(:thermostat_id) { readings.first.thermostat.id }

  context 'when the request is valid reading' do
    before { get "/readings?tracking_number=#{tracking_number}&thermostat_id=#{thermostat_id}", as: :json}
    it 'finds a reading' do
      expect(json['data']).not_to eql(nil)
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  context 'when the request is invalid' do
    before { get '/readings', params: {}, as: :json}

    it 'returns status code 422' do
      expect(response).to have_http_status(422)
    end

    it 'returns a validation failure message' do
      expect(response.body)
      .to match(/{\"data\":null,\"message\":\"Invalid input is provided\"}/)
    end
  end
end
