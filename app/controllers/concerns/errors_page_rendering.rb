module ErrorsPageRendering
  extend ActiveSupport::Concern

  HTTP_ERROR_STATUS_CODES = [403, 404, 418, 500, 502, 503].freeze

  private

  def error_page_display_path
    raw = request&.fullpath.to_s.presence || '/'
    Rack::Utils.unescape(raw)
  rescue StandardError
    raw
  end

  def assign_error_page!(code)
    @error_page = true
    c = code.to_i
    c = 500 unless HTTP_ERROR_STATUS_CODES.include?(c)
    @status_code = c
    path = error_page_display_path
    @error_console_key = I18n.t("errors.console_codes.#{c}", default: "http_#{c}")
    @error_lines = I18n.t("errors.console_lines.#{c}", path: path, default: ">_ HTTP #{c}")
  end
end
