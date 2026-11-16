import { AppColors, Radius, Size, Space, Type } from '../theme/Theme';
import { IconButton, TextButton } from '../kit/Kit';
import { CalcKey } from '../components/calculator/CalcKey';
import { CalculatorStore } from '../model/CalculatorStore';
import { HistoryStore } from '../model/HistoryStore';
import { SettingsStore } from '../model/SettingsStore';
import { CalcResult } from '../model/CalcResult';
import { InputEdit } from '../model/InputEdit';
import { History } from '../model/History';
import { BackBridge, HomeShown } from '../common/BackBridge';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { vibrator } from '@kit.SensorServiceKit';
import { window } from '@kit.ArkUI';
import type { common, Want } from '@kit.AbilityKit';

@ComponentV2
export struct CalculatorPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local input: string = '';
  @Local resultText: string = '';
  @Local errRes: Resource | null = null;
  @Local errorShown: boolean = false;
  @Provider('calcPill') sci: boolean = false;
  @Provider('calcAmoled') amoled: boolean = false;
  @Local inv: boolean = false;
  @Local rad: boolean = false;
  @Local split: boolean = false;
  @Local modulo: boolean = true;
  @Local historyOn: boolean = true;
  @Local swipeDelete: boolean = true;
  @Local history: History[] = [];
  @Local panelOpen: boolean = false;
  @Local menuShown: boolean = false;
  @Local donateShown: boolean = false;
  private caret: number = 0;
  private lastEquals: boolean = false;
  private numbering: number = 0;
  private seenSci: boolean = false;
  private seenRad: boolean = false;
  private ctrl: TextInputController = new TextInputController();
  private scroller: Scroller = new Scroller();
  private calc: CalculatorStore = CalculatorStore.getInstance();
  private store: HistoryStore = HistoryStore.getInstance();

  aboutToAppear(): void {
    const s = SettingsStore.getInstance().current();
    this.sci = s.scientificModeByDefault;
    this.rad = s.useRadiansByDefault;
    this.seenSci = s.scientificModeByDefault;
    this.seenRad = s.useRadiansByDefault;
    this.applySettings();
    this.loadHistory();
    HomeShown.set(() => { this.onReturn(); });
    BackBridge.set(() => this.onBack());
  }

  aboutToDisappear(): void {
    HomeShown.set(null);
    BackBridge.set(null);
  }

  private onBack(): boolean {
    if (this.donateShown) {
      this.donateShown = false;
      return true;
    }
    if (this.panelOpen) {
      this.panelOpen = false;
      return true;
    }
    return false;
  }

  private applySettings(): void {
    const s = SettingsStore.getInstance().current();
    this.split = s.splitParenthesisButton;
    this.modulo = s.addModuloButton;
    this.swipeDelete = s.deleteHistoryOnSwipe;
    this.historyOn = s.historySize !== 0;
    if (!this.historyOn) {
      this.panelOpen = false;
    }
    this.numbering = s.numberingSystem;
    this.amoled = s.themeStyle === 3;
    this.keepAwake(s.preventPhoneFromSleepingMode);
  }

  private keepAwake(on: boolean): void {
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      window.getLastWindow(ctx).then((w: window.Window) => {
        w.setWindowKeepScreenOn(on).catch((e: Error) => {
          hilog.error(0x0001, 'Calc', 'keepScreenOn failed: %{public}s', JSON.stringify(e));
        });
      }).catch((e: Error) => {
        hilog.error(0x0001, 'Calc', 'getLastWindow failed: %{public}s', JSON.stringify(e));
      });
    } catch (e) {
      hilog.error(0x0001, 'Calc', 'keepAwake failed: %{public}s', JSON.stringify(e));
    }
  }

  private async onReturn(): Promise<void> {
    const s = SettingsStore.getInstance().current();
    if (s.scientificModeByDefault !== this.seenSci) {
      this.seenSci = s.scientificModeByDefault;
      this.sci = s.scientificModeByDefault;
    }
    if (s.useRadiansByDefault !== this.seenRad) {
      this.seenRad = s.useRadiansByDefault;
      this.rad = s.useRadiansByDefault;
    }
    this.applySettings();
    try {
      await this.store.trimToSize(s.historySize);
    } catch (e) {
      hilog.error(0x0001, 'Calc', 'trim failed: %{public}s', JSON.stringify(e));
      this.fail();
    }
    this.loadHistory();
    if (this.input.length > 0 && !this.errorShown) {
      this.input = this.calc.formatInput(this.input, this.numbering);
      this.recompute(false);
    }
  }

  private async loadHistory(): Promise<void> {
    try {
      this.history = await this.store.getAll();
    } catch (e) {
      hilog.error(0x0001, 'Calc', 'history load failed: %{public}s', JSON.stringify(e));
      this.fail();
    }
  }

  private buzz(): void {
    if (!SettingsStore.getInstance().current().vibrationMode) {
      return;
    }
    try {
      vibrator.startVibration({ type: 'time', duration: 20 }, { id: 0, usage: 'touch' }).catch((e: Error) => {
        hilog.warn(0x0001, 'Calc', 'vibration failed: %{public}s', JSON.stringify(e));
      });
    } catch (e) {
      hilog.warn(0x0001, 'Calc', 'vibration threw: %{public}s', JSON.stringify(e));
    }
  }

  private recompute(save: boolean): void {
    this.errRes = null;
    if (this.input.length === 0) {
      this.resultText = '';
      return;
    }
    const s = SettingsStore.getInstance().current();
    const r: CalcResult = this.calc.evaluate(this.input, !this.rad, s.numberPrecision, s.numberIntoScientificNotation, this.numbering);
    if (r.ok && r.value !== this.input) {
      this.resultText = r.value;
      if (save && s.autoSaveCalculationWithoutEqualButton) {
        this.store.autoSave(this.input, r.value, s.historySize).then(() => { this.loadHistory(); }).catch((e: Error) => {
          hilog.error(0x0001, 'Calc', 'autosave failed: %{public}s', JSON.stringify(e));
          this.fail();
        });
      }
    } else {
      this.resultText = '';
    }
  }

  private apply(e: InputEdit): void {
    this.input = e.text;
    this.caret = e.caret;
    this.lastEquals = false;
    this.errorShown = false;
    this.recompute(true);
    const c = e.caret;
    setTimeout(() => { this.ctrl.caretPosition(c); }, 0);
  }

  private clampCaret(): number {
    return Math.max(0, Math.min(this.caret, this.input.length));
  }

  private insert(value: string): void {
    let t = this.input;
    let c = this.clampCaret();
    if (this.lastEquals && /^[0-9.]+$/.test(value)) {
      t = '';
      c = 0;
    }
    this.apply(this.calc.insertValue(t, c, value, this.numbering));
  }

  private symbol(sym: string): void {
    this.apply(this.calc.addSymbol(this.input, this.clampCaret(), sym, this.numbering));
  }

  private clearAll(): void {
    this.store.endAutoSave();
    this.input = '';
    this.caret = 0;
    this.lastEquals = false;
    this.errorShown = false;
    this.recompute(false);
  }

  private async equals(): Promise<void> {
    if (this.input.length === 0) {
      return;
    }
    const s = SettingsStore.getInstance().current();
    const r: CalcResult = this.calc.evaluate(this.input, !this.rad, s.numberPrecision, s.numberIntoScientificNotation, this.numbering);
    if (r.ok) {
      const calcText = this.input;
      this.input = r.value;
      this.caret = r.value.length;
      this.resultText = '';
      this.errRes = null;
      this.errorShown = false;
      this.lastEquals = true;
      try {
        await this.store.addFromEquals(calcText, r.value, s.historySize);
        await this.loadHistory();
      } catch (e) {
        hilog.error(0x0001, 'Calc', 'save failed: %{public}s', JSON.stringify(e));
        this.fail();
      }
      this.store.endAutoSave();
    } else {
      this.errRes = this.calc.errorMessage(r);
      this.errorShown = this.calc.isErrorColoured(r);
      this.resultText = '';
      this.lastEquals = true;
    }
  }

  private fn(plain: string, inverse: string): void {
    this.insert(this.inv ? inverse : plain);
  }

  private onKey(id: string): void {
    this.buzz();
    switch (id) {
      case 'squareButton':
        if (!this.inv) {
          this.insert('√');
        } else if (this.modulo) {
          this.insert('#');
        } else {
          const e = this.calc.addSymbol(this.input, this.clampCaret(), '^', this.numbering);
          this.apply(this.calc.insertValue(e.text, e.caret, '2', this.numbering));
        }
        break;
      case 'piButton': this.insert('π'); break;
      case 'exponentButton': this.symbol('^'); break;
      case 'factorialButton': this.symbol('!'); break;
      case 'scientistModeSwitchButton': this.sci = !this.sci; break;
      case 'degreeButton': this.rad = !this.rad; this.recompute(false); break;
      case 'invButton': this.inv = !this.inv; break;
      case 'sineButton': this.fn('sin(', 'sin⁻¹('); break;
      case 'cosineButton': this.fn('cos(', 'cos⁻¹('); break;
      case 'tangentButton': this.fn('tan(', 'tan⁻¹('); break;
      case 'eButton': this.insert('e'); break;
      case 'naturalLogarithmButton': this.fn('ln(', 'e^'); break;
      case 'logarithmButton': this.fn('log(', '10^'); break;
      case 'log2Button': this.fn('log₂(', '2^'); break;
      case 'clearButton': this.clearAll(); break;
      case 'parenthesesButton':
        this.apply(this.calc.addParentheses(this.input, this.clampCaret(), this.numbering));
        break;
      case 'leftParenthesisButton': this.insert('('); break;
      case 'rightParenthesisButton': this.insert(')'); break;
      case 'divideBy100Button': this.symbol('%'); break;
      case 'divideButton': this.symbol('÷'); break;
      case 'multiplyButton': this.symbol('×'); break;
      case 'subtractButton': this.symbol('-'); break;
      case 'addButton': this.symbol('+'); break;
      case 'pointButton':
        if (this.lastEquals) {
          this.input = '';
          this.caret = 0;
        }
        this.apply(this.calc.addPoint(this.input, this.clampCaret(), this.numbering));
        break;
      case 'backspaceButton':
        this.apply(this.calc.backspace(this.input, this.clampCaret(), this.numbering));
        break;
      case 'equalsButton': this.equals(); break;
      default: {
        const names: string[] = ['zeroButton', 'oneButton', 'twoButton', 'threeButton', 'fourButton',
          'fiveButton', 'sixButton', 'sevenButton', 'eightButton', 'nineButton'];
        const idx = names.indexOf(id);
        if (idx >= 0) {
          this.insert(`${idx}`);
        }
      }
    }
  }

  private squareLabel(): string {
    if (!this.inv) {
      return '√';
    }
    return this.modulo ? '#' : 'x²';
  }

  private openUrl(url: string): void {
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.viewData', entities: ['entity.system.browsable'], uri: url };
      ctx.startAbility(want).catch((e: Error) => {
        hilog.warn(0x0001, 'Calc', 'open url failed: %{public}s', JSON.stringify(e));
      });
    } catch (e) {
      hilog.warn(0x0001, 'Calc', 'open url threw: %{public}s', JSON.stringify(e));
    }
  }

  private copyText(text: string): void {
    if (!SettingsStore.getInstance().current().longClickToCopyValue || text.length === 0) {
      return;
    }
    try {
      pasteboard.getSystemPasteboard().setData(pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)).then(() => {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.calculator_copied') });
      }).catch((e: Error) => {
        hilog.error(0x0001, 'Calc', 'copy failed: %{public}s', JSON.stringify(e));
      });
    } catch (e) {
      hilog.error(0x0001, 'Calc', 'copy threw: %{public}s', JSON.stringify(e));
    }
  }

  private pick(text: string): void {
    this.panelOpen = false;
    this.insert(`(${text})`);
  }

  @Builder
  emptyKeyboard() {
    Column().height(0)
  }

  @Builder
  menu() {
    Menu() {
      MenuItem({ content: $r('app.string.calculator_clear_history') }).id('app_menu_clear_history_button')
        .onClick(() => {
          this.store.clear().then(() => { this.loadHistory(); }).catch((e: Error) => {
            hilog.error(0x0001, 'Calc', 'clear failed: %{public}s', JSON.stringify(e));
            this.fail();
          });
        })
      MenuItem({ content: $r('app.string.title_Settings') }).id('app_menu_settings_button')
        .onClick(() => { this.pathStack.pushPathByName('Settings', ''); })
      MenuItem({ content: $r('app.string.title_About') }).id('app_menu_about_button')
        .onClick(() => { this.pathStack.pushPathByName('About', ''); })
      MenuItem({ content: $r('app.string.calculator_support_us') }).id('app_menu_donate_button')
        .onClick(() => { this.donateShown = true; })
    }
  }

  @Builder
  zeroMenu() {
    Menu() {
      MenuItem({ content: '00' }).onClick(() => { this.insert('00'); })
      MenuItem({ content: '000' }).onClick(() => { this.insert('000'); })
    }
  }

  @Builder
  display() {
    Column() {
      Row() {
        if (this.sci) {
          Text(this.rad ? 'RAD' : 'DEG')
            .id('degreeTextView')
            .fontSize(Type.secondary)
            .fontColor(AppColors.textSecondary)
            .constraintSize({ minHeight: 24, minWidth: 40 })
        }
        Blank()
        Column({ space: 4 }) {
          Circle().width(5).height(5).fill(AppColors.icon)
          Circle().width(5).height(5).fill(AppColors.icon)
          Circle().width(5).height(5).fill(AppColors.icon)
        }
        .id('menuButton')
        .width(Size.tap)
        .height(Size.tap)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => { this.menuShown = true; })
        .bindMenu(this.menuShown, this.menu, { onDisappear: () => { this.menuShown = false; } })
      }
      .width('100%')
      .padding({ top: Space.l })
      TextInput({ text: this.input, controller: this.ctrl })
        .id('input')
        .enableKeyboardOnFocus(false)
        .customKeyboard(this.emptyKeyboard())
        .fontSize(Type.display)
        .fontColor(this.errorShown ? $r('app.color.calculator_error') : AppColors.textPrimary)
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding(0)
        .width('100%')
        .height(64)
        .onChange((value: string) => {
          if (value !== this.input) {
            this.input = value;
            this.lastEquals = false;
            this.errorShown = false;
            this.recompute(true);
          }
        })
        .onTextSelectionChange((start: number, end: number) => { this.caret = end; })
      Text(this.errRes ? this.errRes : this.resultText)
        .id('resultDisplay')
        .fontSize(Type.title)
        .fontColor(this.errorShown ? $r('app.color.calculator_error') : AppColors.textSecondary)
        .textAlign(TextAlign.End)
        .width('100%')
        .constraintSize({ minHeight: 32 })
        .maxLines(1)
        .gesture(LongPressGesture().onAction(() => { this.copyText(this.resultText); }))
      Blank()
      if (this.historyOn) {
        Column() {
          Column()
            .width(48)
            .height(5)
            .borderRadius(3)
            .backgroundColor(AppColors.textTertiary)
        }
        .id('history_sliding_layout_button')
        .width('100%')
        .height(Size.tap)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.panelOpen = !this.panelOpen; })
      } else {
        Column().height(Size.tap)
      }
    }
    .width('100%')
    .height(240)
    .padding({ left: Space.l, right: Space.l })
    .backgroundColor(this.amoled ? $r('app.color.calculator_amoled') : $r('app.color.calculator_panel'))
    .borderRadius({ bottomLeft: Radius.l * 2, bottomRight: Radius.l * 2 })
  }

  @Builder
  sciRows() {
    Row() {
      CalcKey({ label: this.rad ? 'DEG' : 'RAD', eid: 'degreeButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('degreeButton'); } })
      CalcKey({ label: this.inv ? 'sin⁻¹' : 'sin', eid: 'sineButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('sineButton'); } })
      CalcKey({ label: this.inv ? 'cos⁻¹' : 'cos', eid: 'cosineButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('cosineButton'); } })
      CalcKey({ label: this.inv ? 'tan⁻¹' : 'tan', eid: 'tangentButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('tangentButton'); } })
    }
    Row() {
      CalcKey({ label: $r('app.string.calculator_inv'), eid: 'invButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('invButton'); } })
      CalcKey({ label: 'e', eid: 'eButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('eButton'); } })
      CalcKey({ label: this.inv ? 'e^' : 'ln', eid: 'naturalLogarithmButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('naturalLogarithmButton'); } })
      CalcKey({ label: this.inv ? '10^' : 'log', eid: 'logarithmButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('logarithmButton'); } })
      CalcKey({ label: this.inv ? '2^' : 'log₂', eid: 'log2Button', kind: 4, keyHeight: 48, onTap: () => { this.onKey('log2Button'); } })
    }
  }

  @Builder
  keypad() {
    Column() {
      Row() {
        CalcKey({ label: this.squareLabel(), eid: 'squareButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('squareButton'); } })
        CalcKey({ label: 'π', eid: 'piButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('piButton'); } })
        CalcKey({ label: '^', eid: 'exponentButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('exponentButton'); } })
        CalcKey({ label: '!', eid: 'factorialButton', kind: 4, keyHeight: 48, onTap: () => { this.onKey('factorialButton'); } })
        CalcKey({
          symbol: this.sci ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'), eid: 'scientistModeSwitchButton',
          kind: 1, keyHeight: 48, onTap: () => { this.onKey('scientistModeSwitchButton'); }
        })
      }
      if (this.sci) {
        this.sciRows()
      }
      Row() {
        if (this.split) {
          CalcKey({ label: '(', eid: 'leftParenthesisButton', kind: 1, onTap: () => { this.onKey('leftParenthesisButton'); } })
          CalcKey({ label: ')', eid: 'rightParenthesisButton', kind: 1, onTap: () => { this.onKey('rightParenthesisButton'); } })
        } else {
          CalcKey({ label: $r('app.string.calculator_ac'), eid: 'clearButton', kind: 2, onTap: () => { this.onKey('clearButton'); } })
          CalcKey({ label: '( )', eid: 'parenthesesButton', kind: 1, onTap: () => { this.onKey('parenthesesButton'); } })
        }
        CalcKey({ label: '%', eid: 'divideBy100Button', kind: 1, onTap: () => { this.onKey('divideBy100Button'); } })
        CalcKey({ label: '÷', eid: 'divideButton', kind: 1, onTap: () => { this.onKey('divideButton'); } })
      }
      Row() {
        CalcKey({ label: '7', eid: 'sevenButton', onTap: () => { this.onKey('sevenButton'); } })
        CalcKey({ label: '8', eid: 'eightButton', onTap: () => { this.onKey('eightButton'); } })
        CalcKey({ label: '9', eid: 'nineButton', onTap: () => { this.onKey('nineButton'); } })
        CalcKey({ label: '×', eid: 'multiplyButton', kind: 1, onTap: () => { this.onKey('multiplyButton'); } })
      }
      Row() {
        CalcKey({ label: '4', eid: 'fourButton', onTap: () => { this.onKey('fourButton'); } })
        CalcKey({ label: '5', eid: 'fiveButton', onTap: () => { this.onKey('fiveButton'); } })
        CalcKey({ label: '6', eid: 'sixButton', onTap: () => { this.onKey('sixButton'); } })
        CalcKey({ label: '−', eid: 'subtractButton', kind: 1, onTap: () => { this.onKey('subtractButton'); } })
      }
      Row() {
        CalcKey({ label: '1', eid: 'oneButton', onTap: () => { this.onKey('oneButton'); } })
        CalcKey({ label: '2', eid: 'twoButton', onTap: () => { this.onKey('twoButton'); } })
        CalcKey({ label: '3', eid: 'threeButton', onTap: () => { this.onKey('threeButton'); } })
        CalcKey({ label: '+', eid: 'addButton', kind: 1, onTap: () => { this.onKey('addButton'); } })
      }
      Row() {
        CalcKey({
          label: '0', eid: 'zeroButton', zeroMenu: true,
          onTap: () => { this.onKey('zeroButton'); },
          onInsert: (v: string) => { this.insert(v); }
        })
        CalcKey({ label: '.', eid: 'pointButton', onTap: () => { this.onKey('pointButton'); } })
        CalcKey({
          label: '⌫', eid: 'backspaceButton',
          onTap: () => { this.onKey('backspaceButton'); },
          onLong: () => { this.buzz(); this.clearAll(); }
        })
        CalcKey({ label: '=', eid: 'equalsButton', kind: 3, onTap: () => { this.onKey('equalsButton'); } })
      }
    }
    .width('100%')
    .padding({ left: Space.s, right: Space.s, top: Space.s, bottom: Space.s })
    .justifyContent(FlexAlign.End)
    .layoutWeight(1)
  }

  @Builder
  historyPanel() {
    Column() {
      if (this.history.length === 0) {
        Text($r('app.string.calculator_no_history'))
          .id('no_history_text')
          .fontSize(Type.body)
          .fontColor(AppColors.textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .constraintSize({ minHeight: 24 })
          .margin({ top: Space.xxl })
      } else {
        List({ scroller: this.scroller, initialIndex: Math.max(0, this.history.length - 1) }) {
          Repeat<History>(this.history).each((ri: RepeatItem<History>) => {
            ListItem() {
              Column() {
                if (ri.index === 0 || !this.store.sameDay(this.history[ri.index - 1], ri.item)) {
                  Text(this.store.dateLabel(ri.item.time))
                    .id('history_time')
                    .fontSize(Type.caption)
                    .fontColor(AppColors.textSecondary)
                    .width('100%')
                    .textAlign(TextAlign.End)
                    .constraintSize({ minHeight: 24 })
                }
                Text(ri.item.calculation)
                  .id('history_item_calculation')
                  .fontSize(Type.secondary)
                  .fontColor(AppColors.textSecondary)
                  .width('100%')
                  .textAlign(TextAlign.End)
                  .constraintSize({ minHeight: 24 })
                  .onClick(() => { this.pick(ri.item.calculation); })
                  .gesture(LongPressGesture().onAction(() => { this.copyText(ri.item.calculation); }))
                Text(ri.item.result)
                  .id('history_item_result')
                  .fontSize(Type.title)
                  .fontColor(AppColors.textPrimary)
                  .width('100%')
                  .textAlign(TextAlign.End)
                  .constraintSize({ minHeight: 32 })
                  .onClick(() => { this.pick(ri.item.result); })
                  .gesture(LongPressGesture().onAction(() => { this.copyText(ri.item.result); }))
              }
              .id(`history_item_${ri.index}`)
              .padding({ left: Space.l, right: Space.l, top: Space.s, bottom: Space.s })
            }
            .swipeAction({
              end: this.swipeDelete ? {
                builder: () => { this.deleteSwipe(); },
                onAction: () => { this.removeEntry(ri.item.id); }
              } : undefined
            })
          }).key((item: History) => `${item.id}_${item.calculation}_${item.result}`).virtualScroll()
        }
        .id('history_recylcle_view')
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.background)
  }

  @Builder
  deleteSwipe() {
    Column().width(1).height(1)
  }

  private removeEntry(id: string): void {
    this.store.remove(id).then(() => { this.loadHistory(); }).catch((e: Error) => {
      hilog.error(0x0001, 'Calc', 'remove failed: %{public}s', JSON.stringify(e));
      this.fail();
    });
  }

  private fail(): void {
    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.calculator_failed') });
  }

  @Builder
  donateButton(label: Resource, id: string, bg: Resource, fg: Resource, url: string) {
    Row() {
      Text(label)
        .fontSize(Type.body)
        .fontColor(fg)
        .maxLines(1)
    }
    .id(id)
    .width('100%')
    .height(Size.button)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bg)
    .borderRadius(Radius.m)
    .onClick(() => { this.openUrl(url); })
  }

  @Builder
  donateDialog() {
    Column() {
      Column({ space: Space.m }) {
        Text($r('app.string.calculator_support_us'))
          .id('alertTitle')
          .fontSize(Type.subtitle)
          .fontColor(AppColors.textPrimary)
          .constraintSize({ minHeight: 24 })
        this.donateButton($r('app.string.calculator_paypal'), 'paypalImage', $r('app.color.calculator_paypal'),
          $r('app.color.calculator_white'), 'https://www.paypal.me/ImDarkempire')
        this.donateButton($r('app.string.calculator_bmac'), 'bmacImage', $r('app.color.calculator_bmac'),
          $r('app.color.calculator_black'), 'https://www.buymeacoffee.com/darkempire78')
        this.donateButton($r('app.string.calculator_github'), 'githubImage', $r('app.color.calculator_github'),
          $r('app.color.calculator_white'), 'https://github.com/sponsors/Darkempire78')
        Row() {
          Blank()
          TextButton({ label: $r('app.string.calculator_close'), eid: 'button1', onTap: () => { this.donateShown = false; } })
        }.width('100%')
      }
      .width('86%')
      .padding(Space.l)
      .backgroundColor(AppColors.surface)
      .borderRadius(Radius.l)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.scrim)
    .onClick(() => { this.donateShown = false; })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.display()
        Stack({ alignContent: Alignment.TopStart }) {
          this.keypad()
          if (this.panelOpen) {
            this.historyPanel()
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      if (this.donateShown) {
        this.donateDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.amoled ? $r('app.color.calculator_amoled') : AppColors.background)
    .id('page_Calculator')
  }
}
