Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'javascripts')
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'icons')

Rails.application.config.assets.precompile += %w[
  auth/verify.js
  A_Logo.svg
  A_ArrowButtonIcon.svg
  Q_ArrowDividerIcon.svg
  Q_ArrowIcon.svg
  Q_ArrowRightIcon.svg
  Q_AudioIcon.svg
  Q_BreadcrumbArticleIcon.svg
  Q_BreadcrumbHomeIcon.svg
  Q_BreadcrumbWeekIcon.svg
  Q_ConsoleIcon.svg
  Q_DragIcon.svg
  Q_EyeIcon.svg
  Q_FilterIcon.svg
  Q_FolderIcon.svg
  Q_LinkIcon.svg
  Q_PasswordNonVisionIcon.svg
  Q_PasswordVisionIcon.svg
  Q_FullScreenIcon
  Q_NotFullScreenIcon
  Q_CloseIcon
]