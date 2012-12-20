module PrivateIssues
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        alias_method_chain :find_issue, :private_issues
        
        alias_method_chain :create, :update_private_attribute
        alias_method_chain :update, :update_private_attribute
      end
    end

    module InstanceMethods
      def create_with_update_private_attribute
        create_without_update_private_attribute
        update_private_attribute(@issue) if @issue.valid?
      end

      def update_with_update_private_attribute
        update_without_update_private_attribute
        update_private_attribute(@issue) if @issue.valid?
      end

      private

      def find_issue_with_private_issues
        find_issue_without_private_issues
        deny_access if @issue and !@issue.private_issue_visible?(@project, User.current)
      end

      # Update private attrribute for all child or parent for the current issue
      def update_private_attribute(issue)
        if issue.root_id
          root_issue = issue.root
          if root_issue
            private = issue.private? ? 1 : 0
            Issue.update_all("private = #{private}", ["root_id = ? ", root_issue.id])
          end
        end
      end

    end
  end
end