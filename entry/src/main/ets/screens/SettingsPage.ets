// Screen "Settings": Change how the calculator behaves; every change is saved at once. An app bar with a back arrow (settings_back_button) and the title "Settings" (settings_back_button_text), then a scrolling list (not lazy) of rows with an icon on the left, a title and a grey description, a switch on the right for the on/off ones, and blue capital category headers. GENERAL: "Language" with the system language name as summary (settings_language, summary settings_language_summary, e.g. "English"; display only); "Theme" (settings_theme, summary settings_theme_summary) opens a single-choice dialog "System (Material You)", "Light", "Dark", "Amoled"; "Numbering System" (settings_numbering_system, summary settings_numbering_system_summary) opens a single-choice dialog "International Numbering System", "Indian Numbering System"; "Vibration" / "Vibrate when a button is pressed" (settings_vibration_switch, on); "Radians" / "Use radians instead of degrees by default" (settings_radians_switch, off); "Scientific mode" / "Activate scientific mode by default" (settings_scientific_mode_switch, off); "Split the parentheses button into two buttons" / "Remove the \"AC\" button to split the parentheses button into two buttons" (settings_split_parenthesis_switch, off); "Add a modulo button" / "Replace the \"X²\" button with a modulo button (available when the \"INV\" button is pressed)" (settings_modulo_switch, on). FORMATTING: "Number of decimal places" with the value as summary (settings_precision, default 10) opens a single-choice dialog 0 to 20, 25, 30, 40, 50, 75, 100, ∞; "Number into scientific notation" / "Convert all results to scientific notation" (settings_scientific_notation_switch, off). HISTORY: "Results saved in history" with the value as summary (settings_history_size, default 50) opens a single-choice dialog 0, 10, 20, 50, 100, 200, 500, 1000, ∞; "Allow selective history deletion" / "Delete specific history element on swipe" (settings_delete_on_swipe_switch, on); "Automatically save calculations" / "Automatically save calculations in history without needing to click the equal button" (settings_auto_save_switch, on). ADVANCED: "Long press to copy value" / "Long press copies the text of the item instead of selecting it" (settings_long_click_copy_switch, on); "Keep device awake" / "Prevent device from sleeping while the app is in the foreground" (settings_prevent_sleep_switch, off). A picked dialog option closes the dialog and updates the row summary at once.
// Keep the root id 'page_Settings', the pathStack consumer and this frame (Stack > Column > AppBar, then
// the content): the factory's walker and the navigation host rely on them. Dialogs and a floating button go
// last in the Stack. Push other screens with this.pathStack.pushPathByName(<name>, <string param>).
import { AppColors } from '../theme/Theme';
import { AppBar } from '../kit/Kit';

@ComponentV2
export struct SettingsPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          AppBar({ title: $r('app.string.title_Settings'), backId: 'settings_back_button', onBack: () => { this.pathStack.pop(); } })
          // TODO(factory): implement Settings
          Text('TODO(factory): implement Settings')
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.background)
    }
    .hideTitleBar(true)
    .id('page_Settings')
  }
}
