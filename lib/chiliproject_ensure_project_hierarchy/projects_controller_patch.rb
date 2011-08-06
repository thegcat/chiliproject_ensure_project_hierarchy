::Project::IDENTIFIER_SEPARATOR = "-"

module Plugin
  module EnsureProjectHierarchy
    module ProjectsController
      module ClassMethods
        
      end
      
      module InstanceMethods
        private
        
        def new_with_default_identifier_for_new_subprojects
          new_without_default_identifier_for_new_subprojects
          if params[:parent_id]
            parent_project = Project.find params[:parent_id]
            puts "Do I get here? And who is the parent_project? " + parent_project.inspect
            @project.identifier = "#{parent_project.identifier}#{::Project::IDENTIFIER_SEPARATOR}"
            puts "wheeeee! " + @project.inspect
          end
        end
        
        def validate_parent_id_with_identifier_hierarchy
          return true if User.current.admin?
          return false unless validate_parent_id_without_identifier_hierarchy
          parent_id = params[:project] && params[:project][:parent_id]
          if parent_id || @project.new_record?
            parent = parent_id.blank? ? nil : Project.find_by_id(parent_id.to_i)
            if parent && !@project.identifier.match("#{Regexp.escape(parent.identifier + ::Project::IDENTIFIER_SEPARATOR)}.+")
              @project.errors.add :identifier, :prefix_invalid, :prefix => "#{parent.identifier}-"
              return false
            end
          end
          true
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          unloadable
          
          alias_method_chain :new, :default_identifier_for_new_subprojects
          alias_method_chain :validate_parent_id, :identifier_hierarchy
        end
      end
    end
  end
end

ProjectsController.send(:include, Plugin::EnsureProjectHierarchy::ProjectsController)