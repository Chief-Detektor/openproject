import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ChangeDetectorRef, Component, DebugElement, Input } from '@angular/core';
import { OpIconComponent } from "core-app/shared/components/icon/icon.component";
import { GitActionsMenuDirective } from "core-app/features/plugins/linked/openproject-gitea_integration/git-actions-menu/git-actions-menu.directive";
import { TabPrsComponent } from "core-app/features/plugins/linked/openproject-gitea_integration/tab-prs/tab-prs.component";
import { HalResourceService } from "core-app/features/hal/services/hal-resource.service";
import { ApiV3Service } from "core-app/core/apiv3/api-v3.service";
import { of } from "rxjs";
import { PullRequestComponent } from "core-app/features/plugins/linked/openproject-gitea_integration/pull-request/pull-request.component";
import { By } from "@angular/platform-browser";
import { I18nService } from "core-app/core/i18n/i18n.service";

@Component({
  selector: 'op-date-time',
  template: '<p>OpDateTimeComponent </p>'
})
class OpDateTimeComponent {
  @Input()
  dateTimeValue:any;
}

describe('TabPrsComponent', () => {
  let component:TabPrsComponent;
  let fixture:ComponentFixture<TabPrsComponent>;
  let element:DebugElement;
  let halResourceService: jasmine.SpyObj<HalResourceService>;
  let changeDetectorRef: jasmine.SpyObj<ChangeDetectorRef>;
  const I18nServiceStub = {
    t: function(key:string) {
      return 'test translation';
    }
  }
  const ApiV3Stub = {
    work_packages: {
      id: () => ({gitea_pull_requests: 'prpath'})
    }
  }
  const pullRequests = {
    elements: [
      {
        title: 'title 1',
        giteaUser: {
          avatarUrl: 'giteaUser 1 avatarUrl',
          htmlUrl: 'giteaUser 1 htmlUrl',
          login: 'giteaUser 1 login',
        },
        giteaUpdatedAt: 'giteaUser 1 giteaUpdatedAt',
        repository: 'giteaUser 1 repository',
        number: 'giteaUser 1 number',
        checkRuns: [
          {
            name: 'giteaUser 1 checkRun',
            outputTitle: 'giteaUser 1 outputTitle',
            conclusion: 'giteaUser 1 conclusion',
            status: 'giteaUser 1 status',
            detailsUrl: 'giteaUser 1 detailsUrl',
          }
        ],
      },
      {
        title: 'title 2',
        giteaUser: {
          avatarUrl: 'giteaUser 2 avatarUrl',
          htmlUrl: 'giteaUser 2 htmlUrl',
          login: 'giteaUser 2 login',
        },
        giteaUpdatedAt: 'giteaUser 2 giteaUpdatedAt',
        repository: 'giteaUser 2 repository',
        number: 'giteaUser 2 number',
        checkRuns: [
          {
            name: 'giteaUser 2 checkRun',
            outputTitle: 'giteaUser 2 outputTitle',
            conclusion: 'giteaUser 2 conclusion',
            status: 'giteaUser 2 status',
            detailsUrl: 'giteaUser 2 detailsUrl',
          }
        ],
      }
    ]
  }

  beforeEach(async () => {
    const halResourceServiceSpy = jasmine.createSpyObj('HalResourceService', ['get']);
    const changeDetectorSpy = jasmine.createSpyObj('ChangeDetectorRef', ['detectChanges']);
    // @ts-ignore
    halResourceServiceSpy.get.and.returnValue(of(pullRequests));

    await TestBed
      .configureTestingModule({
        declarations: [
          TabPrsComponent,
          OpIconComponent,
          GitActionsMenuDirective,
          PullRequestComponent,
          OpDateTimeComponent,
        ],
        providers: [
          { provide: I18nService, useValue: I18nServiceStub },
          { provide: HalResourceService, useValue: halResourceServiceSpy },
          { provide: ApiV3Service, useValue: ApiV3Stub },
          { provide: ChangeDetectorRef, useValue: changeDetectorSpy },
        ],
      })
      .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(TabPrsComponent);
    component = fixture.componentInstance;
    element = fixture.debugElement;
    halResourceService = fixture.debugElement.injector.get(HalResourceService) as jasmine.SpyObj<HalResourceService>;
    changeDetectorRef = fixture.debugElement.injector.get(ChangeDetectorRef) as jasmine.SpyObj<ChangeDetectorRef>;
    // @ts-ignore
    component.workPackage = { id: 'testId' };

    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display a PullRequestComponent per pull request', () => {
    const pullRequests = fixture.debugElement.queryAll(By.css('gitea-pull-request'));

    expect(pullRequests.length).toBe(2);
  });

  it('should display a message when there are no pull requests', () => {
    component.pullRequests$ = of([]);
    fixture.detectChanges();
    const pullRequests = fixture.debugElement.queryAll(By.css('gitea-pull-request'));
    const textMessage = fixture.debugElement.queryAll(By.css('p'));

    expect(pullRequests.length).toBe(0);
    expect(textMessage).toBeTruthy();
  });
});
