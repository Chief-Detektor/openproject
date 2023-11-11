module OpenProject::GiteaIntegration
  module Patches
    module API
      module WorkPackageRepresenter
        module_function

        def extension
          ->(*) do
            link :gitea,
                 cache_if: -> { current_user.allowed_in_project?(:show_gitea_content, represented.project) } do
              {
                href: "#{work_package_path(id: represented.id)}/tabs/gitea",
                title: "gitea"
              }
            end

            link :gitea_pull_requests do
              {
                href: api_v3_paths.gitea_pull_requests_by_work_package(represented.id),
                title: "gitea pull requests"
              }
            end
          end
        end
      end
    end
  end
end
