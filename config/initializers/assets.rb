Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'javascripts')
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'icons')

Rails.application.config.assets.precompile += %w[
  auth/verify.js
]

Rails.application.config.assets.precompile << Proc.new do |path|
  path.start_with?(Rails.root.join('app', 'assets', 'icons').to_s) && path.end_with?('.svg')
end