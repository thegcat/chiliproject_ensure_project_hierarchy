require 'redmine'

Redmine::Plugin.register :chiliproject_ensure_project_hierarchy do
  name 'Ensure Project Hierarchy plugin'
  author 'Felix Schäfer'
  description 'This plugin ensures subproject identifiers are prefixes with their parent project\'s identifier.'
  version '0.0.1'
  url 'https://github.com/thegcat/chiliproject_ensure_project_hierarchy'
  
  ::Project::IDENTIFIER_SEPARATOR = "-"
end
