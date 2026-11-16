// Screen "About": links and app info of OpenCalc.
import { AppColors, Size, Space, Type } from '../theme/Theme';
import { AppBar } from '../kit/Kit';
import { AboutRow } from '../components/about/AboutRow';
import type { common, Want } from '@kit.AbilityKit';

const URL_TRANSLATE: string = 'https://hosted.weblate.org/engage/opencalc/';
const URL_RATE: string = 'https://play.google.com/store/apps/details?id=com.darkempire78.opencalculator';
const URL_GITHUB: string = 'https://github.com/Darkempire78/OpenCalc';
const URL_DISCORD: string = 'https://discord.com/invite/sPvJmY7mcV';
const URL_LICENSE: string = 'https://github.com/Darkempire78/OpenCalc/blob/main/LICENSE';
const URL_PRIVACY: string = 'https://gist.githubusercontent.com/clementwzk/1688314e8b75d5d32ac0503a97ec77a0/raw/2dcc4cf13f9755405e486e51e4658626c289986a/OpenCalc%2520Privacy%2520Policy.md';

@ComponentV2
export struct AboutPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local versionTaps: number = 0;

  private openUrl(url: string): void {
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url
      };
      ctx.startAbility(want).catch(() => {
        // no browser available: nothing to do, as in the original
      });
    } catch (e) {
      // starting the browser failed synchronously: ignored
    }
  }

  private tapVersion(): void {
    this.versionTaps++;
    if (this.versionTaps >= 4) {
      this.versionTaps = 0;
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.about_thanks_toast') });
      } catch (e) {
        this.versionTaps = 0;
      }
    }
  }

  @Builder
  header(label: Resource, eid: string) {
    Text(label)
      .id(eid)
      .width('100%')
      .constraintSize({ minHeight: 24 })
      .fontSize(Type.caption)
      .fontColor($r('app.color.about_header'))
      .padding({ left: Space.l, right: Space.l, top: Space.m })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          AppBar({
            title: $r('app.string.title_About'),
            backId: 'about_back_button',
            titleId: 'about_back_button_text',
            onBack: () => { this.pathStack.pop(); }
          })
          Scroll() {
            Column() {
              this.header($r('app.string.about_help'), 'about_help')
              AboutRow({ symbol: $r('sys.symbol.creditcard'), label: $r('app.string.about_donate'), eid: 'about_donate', onTap: () => {} })
              AboutRow({ symbol: $r('sys.symbol.textformat'), label: $r('app.string.about_translate'), eid: 'about_translate', onTap: () => { this.openUrl(URL_TRANSLATE); } })
              AboutRow({ symbol: $r('sys.symbol.star'), label: $r('app.string.about_rate'), eid: 'about_rate', onTap: () => { this.openUrl(URL_RATE); } })
              Divider().color(AppColors.divider)
              this.header($r('app.string.about_social'), 'about_social')
              AboutRow({ symbol: $r('sys.symbol.keyboard'), label: $r('app.string.about_github'), eid: 'about_github', onTap: () => { this.openUrl(URL_GITHUB); } })
              AboutRow({ symbol: $r('sys.symbol.person_2'), label: $r('app.string.about_discord'), eid: 'about_discord', onTap: () => { this.openUrl(URL_DISCORD); } })
              Divider().color(AppColors.divider)
              this.header($r('app.string.about_category_info'), 'about_category_info')
              AboutRow({ symbol: $r('sys.symbol.doc_text'), label: $r('app.string.about_license'), eid: 'about_license', onTap: () => { this.openUrl(URL_LICENSE); } })
              AboutRow({ symbol: $r('sys.symbol.eye_slash'), label: $r('app.string.about_privacy_policy'), eid: 'about_privacy_policy', onTap: () => { this.openUrl(URL_PRIVACY); } })
              AboutRow({ symbol: $r('sys.symbol.info_circle'), label: $r('app.string.about_app_version'), eid: 'about_app_version', onTap: () => { this.tapVersion(); } })
              Divider().color(AppColors.divider)
              Text($r('app.string.about_made_in_france'))
                .id('about_about_made_in_france')
                .width('100%')
                .constraintSize({ minHeight: 24 })
                .fontSize(Type.secondary)
                .fontColor(AppColors.textSecondary)
                .textAlign(TextAlign.Center)
                .padding({ top: Space.l, bottom: Space.xl })
            }
            .width('100%')
          }
          .align(Alignment.Top)
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.background)
    }
    .hideTitleBar(true)
    .id('page_About')
  }
}
