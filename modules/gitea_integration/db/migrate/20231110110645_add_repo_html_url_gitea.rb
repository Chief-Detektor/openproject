class AddRepoHtmlUrlGitea < ActiveRecord::Migration[7.0]
  def change
    change_table :gitea_pull_requests, bulk: true do |t|
      t.string :repository_html_url
    end

    execute <<~SQL.squish
      UPDATE gitea_pull_requests
      SET repository_html_url = CONCAT(
        substring(gitea_html_url from 0 for position(repository IN gitea_html_url)),
        repository
      )
    SQL
  end
end
