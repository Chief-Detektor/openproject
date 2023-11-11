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

require File.expand_path('../../../../spec_helper', __dir__)

RSpec.describe OpenProject::GiteaIntegration::Services::UpsertGiteaUser do
  subject(:upsert) { described_class.new.call(params) }

  let(:params) do
    {
      'id' => 123,
      'login' => 'test_user',
      'html_url' => 'https://gitea.com/test_user',
      'avatar_url' => 'https://gitea.com/test_user/avatar.jpg'
    }
  end

  it 'creates a new gitea user' do
    expect { upsert }.to change(GiteaUser, :count).by(1)

    expect(GiteaUser.last).to have_attributes(
      gitea_id: 123,
      gitea_login: 'test_user',
      gitea_html_url: 'https://gitea.com/test_user',
      gitea_avatar_url: 'https://gitea.com/test_user/avatar.jpg'
    )
  end

  context 'when a gitea user with that id already exists' do
    let(:gitea_user) do
      create(:gitea_user, gitea_id: 123, gitea_avatar_url: 'https://gitea.com/test_user/old_avatar.jpg')
    end

    it 'updates the gitea user' do
      expect { upsert }.to change { gitea_user.reload.gitea_avatar_url }.from('https://gitea.com/test_user/old_avatar.jpg').to('https://gitea.com/test_user/avatar.jpg')
    end
  end
end
