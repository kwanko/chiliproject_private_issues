module PrivateIssues
  module IssuePatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        named_scope :nonprivate_only, :conditions => {:private => false}
        alias_method_chain :visible?, :private_issues
        #class << self
        #  alias_method_chain :visible_condition, :private_issues
        #end

        safe_attributes 'private',
                        :if => lambda { |issue, user| user.allowed_to?(:manage_private_issues, issue.project) }
      end
    end

    module ClassMethods
      # Returns a SQL conditions string used to find all issues visible by the specified user
      #def visible_condition_with_private_issues(user, options={})
      #  condition = visible_condition_without_private_issues(user, options)
      #  unless user.allowed_to?(:view_private_issues, project)
      #    condition << " AND issues.private='f'"
      #  end
      #
      #  condition << Project.allowed_to_condition(user, :view_private_issues, options)
      #  condition
      #end
    end

    module InstanceMethods
      def private_issue_visible?(project, user)
        if self.private?
          !user.nil? and (user.allowed_to?(:view_private_issues, project) and ((self.author == user) or (self.assigned_to == user) or (self.watched_by? user)))
        else
          true
        end
      end

      def visible_with_private_issues?(user=User.current)
        allowed = visible_without_private_issues?(user)
        if allowed
          return private_issue_visible?(project, user)
        end
        allowed
      end
    end

  end
end