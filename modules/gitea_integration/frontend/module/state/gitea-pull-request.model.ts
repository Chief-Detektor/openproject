import {
  IHalResourceLink,
  IHalResourceLinks,
} from 'core-app/core/state/hal-resource';
import { ID } from '@datorama/akita';

export interface ISnippet {
  id:string;
  name:string;
  textToCopy:() => string
}

export interface IGiteaUserResource {
  avatarUrl:string;
  htmlUrl:string;
  login:string;
}

export interface IGiteaCheckRunResource {
  appOwnerAvatarUrl:string;
  completedAt:string;
  conclusion:string;
  detailsUrl:string;
  htmlUrl:string;
  name:string;
  outputSummary:string;
  outputTitle:string;
  startedAt:string;
  status:string;
}

export interface IGiteaPullRequestResourceLinks extends IHalResourceLinks {
  giteaUser:IHalResourceLink;
  mergedBy?:IHalResourceLink;
  checkRuns?:IHalResourceLink[];
}

export interface IGiteaPullRequestResourceEmbedded {
  giteaUser:IGiteaUserResource;
  mergedBy?:IGiteaUserResource;
  checkRuns:IGiteaCheckRunResource[];
}

export interface IGiteaPullRequest {
  id:ID;
  additionsCount?:number;
  body?:{
    format?:string;
    raw?:string;
    html?:string;
  },
  changedFilesCount?:number;
  commentsCount?:number;
  createdAt?:string;
  deletionsCount?:number;
  draft?:boolean;
  giteaUpdatedAt?:string;
  htmlUrl:string;
  labels?:string[];
  merged?:boolean;
  mergedAt?:string;
  number?:number;
  repository:string;
  repositoryHtmlUrl:string;
  reviewCommentsCount?:number;
  state?:string;
  title:string;
  updatedAt?:string;

  _links:IGiteaPullRequestResourceLinks;
  _embedded:IGiteaPullRequestResourceEmbedded;
}
