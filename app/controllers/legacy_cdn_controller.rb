class LegacyCdnController < ActionController::Base
  skip_forgery_protection

  def show
    name = params[:filename].to_s
    return head :not_found unless name.match?(/\A[a-z0-9._-]+\z/i)

    body = "// Legacy stub for #{name}\nconsole.info('[Inspectra] legacy stub loaded:', #{name.to_json});\n"
    render plain: body, content_type: 'application/javascript'
  end
end
