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

require 'spec_helper'
require_relative '../support/pages/work_package_gitea_tab'

RSpec.describe 'Open the Gitea tab', js: true do
  let(:user) do
    create(:user,
           member_with_roles: { project => role })
  end
  let(:role) do
    create(:project_role,
           permissions: %i(view_work_packages
                           add_work_package_notes
                           show_gitea_content))
  end
  let(:project) { create(:project) }
  let(:work_package) { create(:work_package, project:, subject: 'A test work_package') }
  let(:gitea_tab) { Pages::GiteaTab.new(work_package.id) }
  let(:pull_request) { create(:gitea_pull_request, :open, work_packages: [work_package], title: 'A Test PR title') }
  let(:check_run) { create(:gitea_check_run, gitea_pull_request: pull_request, name: 'a check run name') }

  let(:tabs) { Components::WorkPackages::Tabs.new(work_package) }
  let(:gitea_tab_element) { find('.op-tab-row--link_selected', text: 'gitea') }

  shared_examples_for "a gitea tab" do
    before do
      check_run
      login_as(user)
    end

    # compares the clipboard content by drafting a new comment, pressing ctrl+v and
    # comparing the pasted content against the provided text
    def expect_clipboard_content(text)
      work_package_page.switch_to_tab(tab: 'activity')

      work_package_page.trigger_edit_comment
      work_package_page.update_comment(' ') # ensure the comment editor is fully loaded
      gitea_tab.paste_clipboard_content
      expect(work_package_page.add_comment_container).to have_content(text)

      work_package_page.switch_to_tab(tab: 'gitea')
    end

    it 'shows the gitea tab when the user is allowed to see it' do
      work_package_page.visit!
      work_package_page.switch_to_tab(tab: 'gitea')

      tabs.expect_counter(gitea_tab_element, 1)

      gitea_tab.git_actions_menu_button.click
      gitea_tab.git_actions_copy_branch_name_button.click
      expect(page).to have_text('Copied!')
      expect_clipboard_content("#{work_package.type.name.downcase}/#{work_package.id}-a-test-work_package")

      expect(page).to have_text('A Test PR title')
      expect(page).to have_text('a check run name')
    end

    context 'when there are no pull requests' do
      let(:check_run) {}
      let(:pull_request) {}

      it 'shows the gitea tab with an empty-pull-requests message' do
        work_package_page.visit!
        work_package_page.switch_to_tab(tab: 'gitea')
        tabs.expect_no_counter(gitea_tab_element)
        expect(page).to have_content('There are no pull requests')
        expect(page).to have_content("Link an existing PR by using the code OP##{work_package.id}")
      end
    end

    context 'when the user does not have the permissions to see the gitea tab' do
      let(:role) do
        create(:project_role,
               permissions: %i(view_work_packages
                               add_work_package_notes))
      end

      it 'does not show the gitea tab' do
        work_package_page.visit!

        gitea_tab.expect_tab_not_present
      end
    end

    context 'when the gitea integration is not enabled for the project' do
      let(:project) { create(:project, disable_modules: 'gitea') }

      it 'does not show the gitea tab' do
        work_package_page.visit!

        gitea_tab.expect_tab_not_present
      end
    end
  end

  describe 'work package full view' do
    let(:work_package_page) { Pages::FullWorkPackage.new(work_package) }

    it_behaves_like 'a gitea tab'
  end

  describe 'work package split view' do
    let(:work_package_page) { Pages::SplitWorkPackage.new(work_package) }

    it_behaves_like 'a gitea tab'
  end
end
