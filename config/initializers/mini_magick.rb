# frozen_string_literal: true

vendor_im_path = Rails.root.join('vendor', 'imagemagick')
if vendor_im_path.directory?
  path_sep = File::PATH_SEPARATOR
  env_path = ENV['PATH'].to_s
  vendor_path = vendor_im_path.to_s

  unless env_path.split(path_sep).include?(vendor_path)
    ENV['PATH'] = [vendor_path, env_path].reject(&:empty?).join(path_sep)
  end

  ENV['MAGICK_HOME'] ||= vendor_path
end
