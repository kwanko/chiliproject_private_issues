module PrivateIssues
  module QueryPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        alias_method_chain :statement, :private_issues

      end
    end


    module InstanceMethods
      def statement_with_private_issues
        filters_clauses = statement_without_private_issues

        user = User.current
        if project && user.allowed_to?(:view_private_issues, project)
          # Display privates issues for author and watchers
          filters_clauses << " AND ((issues.private = #{connection.quoted_false} OR issues.author_id = #{user.id} OR issues.assigned_to_id = #{user.id}) OR (issues.private = #{connection.quoted_true} AND #{Issue.table_name}.id IN (SELECT #{Watcher.table_name}.watchable_id FROM #{Watcher.table_name} WHERE #{Watcher.table_name}.watchable_type='Issue' AND #{Watcher.table_name}.user_id = #{user.id})))"
        else
          # Hide private issues
          filters_clauses << " AND (issues.private = #{connection.quoted_false} OR issues.author_id = #{user.id} OR issues.assigned_to_id = #{user.id}) "
        end
      end
    end
  end
end