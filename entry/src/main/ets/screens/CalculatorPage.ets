// Screen "Calculator": Type a calculation on the keypad and read the live result; no app bar. The display panel shows the overflow icon (menuButton, three vertical dots, top right) that opens a popup menu with the items "Clear History" (app_menu_clear_history_button), "Settings" (app_menu_settings_button), "About" (app_menu_about_button) and "Support Us" (app_menu_donate_button); the input line (input, large black text, right-aligned) and the result line (resultDisplay, grey, right-aligned, red #F44B3F with the input on an error after =). Below, a first row of flat text keys without background: √ (squareButton), π (piButton), ^ (exponentButton), ! (factorialButton) and a round pale-blue key with a chevron down/up (scientistModeSwitchButton) that shows or hides two more flat rows: RAD/DEG (degreeButton), sin (sineButton), cos (cosineButton), tan (tangentButton), then INV (invButton), e (eButton), ln (naturalLogarithmButton), log (logarithmButton), log₂ (log2Button), and the DEG/RAD indicator (degreeTextView, grey, top left of the display) appears. Then 5 rows of 4 round keys (they become pill-shaped when the scientific rows are shown): AC (clearButton, pale lavender #E3DCFB), ( ) (parenthesesButton), % (divideBy100Button), ÷ (divideButton); 7 8 9 × (multiplyButton); 4 5 6 − (subtractButton); 1 2 3 + (addButton); 0 (zeroButton) · (pointButton) ⌫ (backspaceButton) = (equalsButton, light blue #C2E7FB); digit keys light grey #EFEFEF, operator keys and ( ) % pale blue #D2E4F3. With Split parentheses on, AC and ( ) are replaced by ( (leftParenthesisButton) and ) (rightParenthesisButton). INV switches the labels to sin⁻¹ cos⁻¹ tan⁻¹ e^ 10^ 2^ and √ to # (modulo, when Add a modulo button is on) or x². Long press on 0 offers 00 and 000; long press on ⌫ clears everything. The history handle (history_sliding_layout_button) slides the history panel down over the keypad: a list (history_recylcle_view) of rows (history_item_0, history_item_1, …), oldest first and scrolled to the newest at the bottom, each with the calculation (history_item_calculation), the result (history_item_result) and a relative day (history_time, shown only on the first row of each day); tapping a calculation or result inserts it wrapped in parentheses; swiping a row sideways deletes it when allowed; tapping the handle again or Back closes the panel. The Support Us dialog has the title "Support Us" (alertTitle), three wide rounded buttons drawn like the original's images: dark blue "Donate on PayPal" (paypalImage), yellow "Buy me a coffee" (bmacImage), charcoal "GitHub Sponsor" with a pink heart (githubImage), and a text button "Close" (button1).
// Keep the root id 'page_Calculator', the pathStack consumer and this frame (Stack > Column > AppBar, then
// the content): the factory's walker and the navigation host rely on them. Dialogs and a floating button go
// last in the Stack. Push other screens with this.pathStack.pushPathByName(<name>, <string param>).
// Back on this (home) screen leaves the app unless a handler consumes it: import { BackBridge } from '../common/BackBridge'
// and BackBridge.set(() => boolean) in aboutToAppear (return true when you closed a panel or dialog), BackBridge.set(null) in aboutToDisappear.
// This screen is not inside a NavDestination, so it has no onShown. To reload when the user comes back from a pushed screen:
// import { HomeShown } from '../common/BackBridge', HomeShown.set(() => { this.reload(); }) in aboutToAppear, HomeShown.set(null) in aboutToDisappear.
import { AppColors } from '../theme/Theme';
import { AppBar } from '../kit/Kit';

@ComponentV2
export struct CalculatorPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        AppBar({ title: $r('app.string.title_Calculator'), showBack: false })
        // TODO(factory): implement Calculator
        Text('TODO(factory): implement Calculator')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.background)
    .id('page_Calculator')
  }
}
