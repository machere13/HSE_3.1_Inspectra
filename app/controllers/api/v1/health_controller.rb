class Api::V1::HealthController < ApplicationController
  def index
    render_success(
      data: {
        timestamp: Time.current.iso8601
      }
    )
  end
end
