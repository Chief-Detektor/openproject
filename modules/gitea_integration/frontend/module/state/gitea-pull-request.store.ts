import { EntityStore, StoreConfig } from '@datorama/akita';
import { IGiteaPullRequest } from 'core-app/features/plugins/linked/openproject-gitea_integration/state/gitea-pull-request.model';
import {
  createInitialResourceState,
  ResourceState,
} from 'core-app/core/state/resource-store';

export interface GiteaPullRequestsState extends ResourceState<IGiteaPullRequest> {
}

@StoreConfig({ name: 'gitea-pull-requests' })
export class GiteaPullRequestsStore extends EntityStore<GiteaPullRequestsState> {
  constructor() {
    super(createInitialResourceState());
  }
}
