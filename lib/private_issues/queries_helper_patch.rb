#-- encoding: UTF-8
# Private issues plugin for Chiliproject
# Copyright (C) 2012  Arnauld NYAKU
# wrap the column_content method to put in evidence a private ticket in the list of tickets
module PrivateIssues
  module QueriesHelperPatch
    def self.included(base) # :nodoc:
       base.send(:include, QueriesHelperPatchMethods)
       base.class_eval do
         unloadable
         alias_method_chain :column_content, :private_issues
       end
    end
  end

  module QueriesHelperPatchMethods
    def column_content_with_private_issues(column, issue)
       content = column_content_without_private_issues(column, issue)

       value = column.value(issue)
       if value.class.name == 'String' && column.name == :subject && issue.private?
         content = link_to(h(value), {:controller => 'issues', :action => 'show', :id => issue}, :class => "icon icon-lock")
       end

       content
    end
  end
end