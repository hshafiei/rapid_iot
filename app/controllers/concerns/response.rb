module Response
  extend ActiveSupport::Concern
  # Renders JSON to the requester
  def json_response(data, status = :ok, message = :successful)
     render json: {data: data, message: I18n.t(message)}, status: status
   end
end
