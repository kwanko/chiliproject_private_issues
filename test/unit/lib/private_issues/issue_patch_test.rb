# -*- encoding : utf-8 -*-
require File.expand_path('../../../../test_helper', __FILE__)

require_dependency 'issue'
class PrivateIssues::IssueTestPatch < ActiveSupport::TestCase

  subject { Issue.new }

  # Based on WikiPageDropTest
  def setup
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project, {:private => true})
    User.current = @user = User.generate!
    @role = Role.generate!(:permissions => [:view_issues])
    Member.generate!(:principal => @user, :project => @project, :roles => [@role])
  end

  context "#visible?" do
    should "not be visible without permission" do
      assert @issue.private
      assert !@issue.visible?
    end

    should "not be visible to user with permission but not author" do
      @role.add_permission! :view_private_issues
      User.current.reload
      assert @issue.author != @user
      assert !@issue.visible?
    end

    should "not be visible to user with permission but not assignee" do
      @role.add_permission! :view_private_issues
      User.current.reload
      assert @issue.assigned_to != @user
      assert !@issue.visible?
    end


    should "not be visible to user with permission but not watcher" do
      @role.add_permission! :view_private_issues
      User.current.reload
      assert !@issue.watched_by?(@user)
      assert !@issue.visible?
    end


    should "be visible to an author with permission" do
      @role.add_permission! :view_private_issues
      User.current.reload
      @issue.author = @user
      assert @issue.visible?
    end


    should "be visible to an assignee with permission" do
      @role.add_permission! :view_private_issues
      User.current.reload
      @issue.assigned_to = @user
      assert @issue.visible?
    end


    should "be visible to a watcher with permission" do
      @role.add_permission! :view_private_issues
      User.current.reload
      Watcher.create!(:user => @user, :watchable => @issue)

      assert @issue.watched_by? @user
      assert @issue.visible?
    end

  end

end
