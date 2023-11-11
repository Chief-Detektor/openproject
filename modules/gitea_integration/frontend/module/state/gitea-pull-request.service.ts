// -- copyright
// OpenProject is an open source project management software.
// Copyright (C) 2012-2023 the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import { Injectable } from '@angular/core';
import { WorkPackageResource } from 'core-app/features/hal/resources/work-package-resource';
import { IGiteaPullRequest } from 'core-app/features/plugins/linked/openproject-gitea_integration/state/gitea-pull-request.model';
import { GiteaPullRequestsStore } from 'core-app/features/plugins/linked/openproject-gitea_integration/state/gitea-pull-request.store';
import { ID } from '@datorama/akita';
import { ResourceStoreService, ResourceStore } from 'core-app/core/state/resource-store.service';
import { Observable } from 'rxjs';

@Injectable()
export class GiteaPullRequestResourceService extends ResourceStoreService<IGiteaPullRequest> {
  ofWorkPackage(workPackage:WorkPackageResource):Observable<IGiteaPullRequest[]> {
    const path = this.workPackagePullRequestsPath(workPackage.id as string);
    return this.requireCollection(path);
  }

  requireSingle(id:ID):Observable<IGiteaPullRequest> {
    return this.requireEntity(this.entityPath(id));
  }

  protected basePath():string {
    return this.apiV3Service.gitea_pull_requests.path;
  }

  protected entityPath(id:ID):string {
    return this.apiV3Service.gitea_pull_requests.id(id).path;
  }

  protected workPackagePullRequestsPath(id:ID):string {
    return this.apiV3Service.work_packages.id(id).gitea_pull_requests.path;
  }

  protected createStore():ResourceStore<IGiteaPullRequest> {
    return new GiteaPullRequestsStore();
  }
}
