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
