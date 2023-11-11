class CreateGiteaTables < ActiveRecord::Migration[7.0]
  # rubocop:disable Metrics/AbcSize
  def change
    # see https://docs.gitea.com/en/rest/reference/pulls
    create_table :gitea_pull_requests do |t|
      t.references :gitea_user
      t.references :merged_by

      t.bigint :gitea_id, unique: true # may be null if we receive a comment and just know the html_url
      t.integer :number, null: false
      t.string :gitea_html_url, null: false, unique: true
      t.string :state, null: false
      t.string :repository, null: false
      t.datetime :gitea_updated_at
      t.string :title
      t.text :body
      t.boolean :draft
      t.boolean :merged
      t.datetime :merged_at
      t.integer :comments_count
      t.integer :review_comments_count
      t.integer :additions_count
      t.integer :deletions_count
      t.integer :changed_files_count
      t.json :labels # [{name, color}]
      t.timestamps
    end

    create_join_table :gitea_pull_requests, :work_packages do |t|
      t.index :gitea_pull_request_id, name: 'gitea_pr_wp_pr_id'
      t.index %i[gitea_pull_request_id work_package_id],
              unique: true,
              name: "unique_index_gt_prs_wps_on_gt_pr_id_and_wp_id"
    end

    # see: https://docs.gitea.com/en/rest/reference/users
    create_table :gitea_users do |t|
      t.bigint :gitea_id, null: false, unique: true
      t.string :gitea_login, null: false
      t.string :gitea_html_url, null: false
      t.string :gitea_avatar_url, null: false

      t.timestamps
    end

    # see: https://docs.gitea.com/en/rest/reference/checks
    create_table :gitea_check_runs do |t|
      t.references :gitea_pull_request, null: false

      t.bigint :gitea_id, null: false, unique: true
      t.string :gitea_html_url, null: false
      t.bigint :app_id, null: false
      t.string :gitea_app_owner_avatar_url, null: false
      t.string :status, null: false
      t.string :name, null: false
      t.string :conclusion
      t.string :output_title
      t.string :output_summary
      t.string :details_url
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
  # rubocop:enable Metrics/AbcSize
end
