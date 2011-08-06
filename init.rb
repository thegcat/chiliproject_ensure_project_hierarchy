require 'redmine'

Redmine::Plugin.register :chiliproject_ensure_project_hierarchy do
  name 'Ensure Project Hierarchy plugin'
  author 'Felix Schäfer'
  description 'This plugin ensures subproject identifiers are prefixes with their parent project\'s identifier.'
  version '1.0.0'
  url 'https://github.com/thegcat/chiliproject_ensure_project_hierarchy'
end

require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'chiliproject_ensure_project_hierarchy/projects_controller_patch'
end