require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do
  let(:project) {mock_model Project}
  let(:parent_project) {mock_model Project, :identifier => "something-witty"}
  
  describe "when I navigate to the new project page after having clicked the 'New subproject' link" do
    let(:do_action) {get :new, :parent_id => parent_project.identifier}
    
    before do
      # not testing the other stuff
      IssueCustomField.stub!(:find)
      Tracker.stub!(:all)

      Project.stub!(:new).and_return project
      Project.stub!(:find).with(parent_project.identifier).and_return parent_project
      @controller.stub!(:authorize_global).and_return true
    end

    describe "then the identifier of the new project" do
      it "should default to the parent's identifier with the project identifier separator" do
        project.should_receive(:identifier=).with "#{parent_project.identifier}#{::Project::IDENTIFIER_SEPARATOR}"
        do_action
      end
    end
  end
  
  describe "when I try to save a project with a parent project" do
    describe "when the project to save is an existing project" do
      let(:do_action) {put :update, :id => "abc", :project => {:parent_id => parent_project.id, :identifier => identifier}}
      let(:project) {mock_model Project, :name => "abc", :parent_id => parent_project.id, :identifier => identifier}
    
      before do
        Project.stub!(:find).with("abc").and_return project
        Project.stub!(:find_by_id).with(parent_project.id).and_return parent_project
        project.stub!(:safe_attributes=)
        project.stub!(:allowed_parents).and_return [parent_project]
        project.stub!(:save).and_return true
        project.stub!(:set_allowed_parent!)
        @controller.stub!(:authorize).and_return true
        @controller.stub!(:load_project_settings)
      end
      
      describe "and the submitted identifier is correct" do
        let(:identifier) {"#{parent_project.identifier}#{::Project::IDENTIFIER_SEPARATOR}abc"}
        
        it "then the creation should be successful" do
          do_action
          response.should be_redirect
        end
      end
      
      describe "and the submitted identifier is incorrect" do
        let(:identifier) {""}
        let(:errors) {mock "ActiveRecord::Errors"}
        
        before do
          project.stub!(:errors).and_return errors
        end
        
        it "then an error should be set on the project" do
          errors.should_receive(:add).with :identifier, :prefix_invalid, :prefix => "#{parent_project.identifier}#{::Project::IDENTIFIER_SEPARATOR}"
          do_action
        end
      end
    end
    
    describe "when the project to save is a new project" do
      # this uses the same validation, no need to test it again
    end
  end
end