class Api::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :set_cors_headers

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  def render_json(data, status: :ok)
    render json: data, status: status
  end
end
