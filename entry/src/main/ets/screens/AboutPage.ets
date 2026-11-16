// Screen "About": Read about the app and open its links. An app bar with a back arrow (about_back_button) and the title "About" (about_back_button_text), then rows with a black icon on the left and the text, grouped under blue capital headers with thin separators between groups: "HELP US" (about_help): "Donate" (about_donate, does nothing, as in the original), "Translate" (about_translate), "Rate this app" (about_rate); "SOCIAL" (about_social): "GitHub" (about_github), "Discord" (about_discord); "APP INFO" (about_category_info): "License GPL 3.0" (about_license), "Privacy policy" (about_privacy_policy), "Version 3.2.0 (53)" (about_app_version; tapping it four times shows the toast "Thanks for using OpenCalc ❤️"); then the line "Made with ❤️ in France" (about_about_made_in_france). Translate opens https://hosted.weblate.org/engage/opencalc/, Rate this app https://play.google.com/store/apps/details?id=com.darkempire78.opencalculator, GitHub https://github.com/Darkempire78/OpenCalc, Discord https://discord.com/invite/sPvJmY7mcV, License https://github.com/Darkempire78/OpenCalc/blob/main/LICENSE, Privacy policy the gist URL in AboutActivity.kt, all in the system browser.
// Keep the root id 'page_About', the pathStack consumer and this frame (Stack > Column > AppBar, then
// the content): the factory's walker and the navigation host rely on them. Dialogs and a floating button go
// last in the Stack. Push other screens with this.pathStack.pushPathByName(<name>, <string param>).
import { AppColors } from '../theme/Theme';
import { AppBar } from '../kit/Kit';

@ComponentV2
export struct AboutPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          AppBar({ title: $r('app.string.title_About'), backId: 'about_back_button', onBack: () => { this.pathStack.pop(); } })
          // TODO(factory): implement About
          Text('TODO(factory): implement About')
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
