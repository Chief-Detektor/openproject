#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

class GiteaPullRequest < ApplicationRecord
  LABEL_KEYS = %w[color name].freeze

  has_and_belongs_to_many :work_packages
  has_many :gitea_check_runs, dependent: :destroy
  belongs_to :gitea_user, optional: true
  belongs_to :merged_by, optional: true, class_name: 'GiteaUser'

  enum state: {
    open: 'open',
    closed: 'closed'
  }

  validates_presence_of :gitea_html_url,
                        :number,
                        :repository,
                        :state,
                        :title,
                        :gitea_updated_at
  validates_presence_of :body,
                        :comments_count,
                        :review_comments_count,
                        :additions_count,
                        :deletions_count,
                        :changed_files_count,
                        unless: :partial?
  validate :validate_labels_schema

  scope :without_work_package, -> { where.missing(:work_packages) }

  def self.find_by_gitea_identifiers(id: nil, url: nil, initialize: false)
    raise ArgumentError, "needs an id or an url" if id.nil? && url.blank?

    found = where(gitea_id: id).or(where(gitea_html_url: url)).take

    if found
      found
    elsif initialize
      new(gitea_id: id, gitea_html_url: url)
    end
  end

  def visible?(user = User.current)
    WorkPackage
      .visible(user)
      .exists?(id: work_packages.select(:id))
  end

  ##
  # When a PR lives long enough and receives many pushes, the same check (say, a CI test run) can be run multiple times.
  # This method only returns the latest of each type of check_run.
  def latest_check_runs
    gitea_check_runs.select("DISTINCT ON (gitea_check_runs.app_id, gitea_check_runs.name) *")
                     .order(app_id: :asc, name: :asc, started_at: :desc)
  end

  def partial?
    [body, comments_count, review_comments_count, additions_count, deletions_count, changed_files_count].all?(&:nil?)
  end

  private

  def validate_labels_schema
    return if labels.nil?
    return if labels.all? { |label| label.keys.sort == LABEL_KEYS }

    errors.add(:labels, 'invalid schema')
  end
end
