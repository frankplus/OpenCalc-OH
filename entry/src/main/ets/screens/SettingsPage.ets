import { AppColors, Radius, Size, Space, Type } from '../theme/Theme';
import { ChoiceRow, IconButton } from '../kit/Kit';
import { SettingHeader, SettingRow } from '../components/settings/SettingRow';
import { CalcSettings } from '../model/CalcSettings';
import { SettingsStore } from '../model/SettingsStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

class Opt {
  label: string = '';
  value: number = 0;
  constructor(label: string, value: number) {
    this.label = label;
    this.value = value;
  }
}

@ComponentV2
export struct SettingsPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local s: CalcSettings = new CalcSettings();
  @Local dialog: number = 0;
  @Local language: string = '';
  @Local failed: boolean = false;
  private store: SettingsStore = SettingsStore.getInstance();

  aboutToAppear() {
    this.reload();
  }

  reload() {
    this.s = this.store.current();
    this.language = this.store.languageName();
  }

  clone(): CalcSettings {
    const o = this.s;
    const n = new CalcSettings();
    n.themeStyle = o.themeStyle;
    n.vibrationMode = o.vibrationMode;
    n.useRadiansByDefault = o.useRadiansByDefault;
    n.scientificModeByDefault = o.scientificModeByDefault;
    n.splitParenthesisButton = o.splitParenthesisButton;
    n.addModuloButton = o.addModuloButton;
    n.numberPrecision = o.numberPrecision;
    n.numberIntoScientificNotation = o.numberIntoScientificNotation;
    n.historySize = o.historySize;
    n.deleteHistoryOnSwipe = o.deleteHistoryOnSwipe;
    n.autoSaveCalculationWithoutEqualButton = o.autoSaveCalculationWithoutEqualButton;
    n.longClickToCopyValue = o.longClickToCopyValue;
    n.preventPhoneFromSleepingMode = o.preventPhoneFromSleepingMode;
    n.numberingSystem = o.numberingSystem;
    return n;
  }

  async commit(n: CalcSettings) {
    try {
      await this.store.save(n);
      this.s = this.store.current();
      this.failed = false;
    } catch (e) {
      hilog.error(0x0001, 'Settings', 'save failed: %{public}s', JSON.stringify(e));
      this.failed = true;
    }
  }

  change(f: (n: CalcSettings) => void) {
    const n = this.clone();
    f(n);
    this.commit(n);
  }

  options(): Opt[] {
    const r: Opt[] = [];
    if (this.dialog === 1) {
      const ctx = this.getUIContext().getHostContext();
      for (let i = 0; i < 4; i++) {
        r.push(new Opt(ctx ? ctx.resourceManager.getStringSync(this.store.themeName(i)) : '', i));
      }
    } else if (this.dialog === 2) {
      const ctx = this.getUIContext().getHostContext();
      for (let i = 0; i < 2; i++) {
        r.push(new Opt(ctx ? ctx.resourceManager.getStringSync(this.store.numberingSystemName(i)) : '', i));
      }
    } else if (this.dialog === 3) {
      for (const v of this.store.precisionOptions()) {
        r.push(new Opt(this.store.precisionLabel(v), v));
      }
    } else if (this.dialog === 4) {
      for (const v of this.store.historySizeOptions()) {
        r.push(new Opt(this.store.historySizeLabel(v), v));
      }
    }
    return r;
  }

  selected(): number {
    if (this.dialog === 1) { return this.s.themeStyle; }
    if (this.dialog === 2) { return this.s.numberingSystem; }
    if (this.dialog === 3) { return this.s.numberPrecision; }
    return this.s.historySize;
  }

  pick(v: number) {
    const d = this.dialog;
    this.dialog = 0;
    this.change((n: CalcSettings) => {
      if (d === 1) { n.themeStyle = v; }
      else if (d === 2) { n.numberingSystem = v; }
      else if (d === 3) { n.numberPrecision = v; }
      else { n.historySize = v; }
    });
    if (d === 1) { this.store.applyTheme(v); }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Row() {
            IconButton({ symbol: $r('sys.symbol.arrow_left'), label: $r('app.string.title_Settings'), eid: 'settings_back_button', onTap: () => { this.pathStack.pop(); } })
            Text($r('app.string.title_Settings'))
              .fontSize(Type.title)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.textPrimary)
              .margin({ left: Space.s })
              .id('settings_back_button_text')
          }
          .width('100%')
          .height(Size.appBar)
          .padding({ left: Space.s, right: Space.l })
          .alignItems(VerticalAlign.Center)
          Scroll() {
            Column() {
              SettingHeader({ title: $r('app.string.settings_general') })
              SettingRow({ symbol: $r('sys.symbol.local'), title: $r('app.string.settings_language_title'), summary: this.language, eid: 'settings_language', summaryId: 'settings_language_summary' })
              SettingRow({ symbol: $r('sys.symbol.paintpalette'), title: $r('app.string.settings_theme_title'), summary: this.store.themeName(this.s.themeStyle), eid: 'settings_theme', summaryId: 'settings_theme_summary', onTap: () => { this.dialog = 1; } })
              SettingRow({ symbol: $r('sys.symbol.list_number'), title: $r('app.string.settings_numbering_title'), summary: this.store.numberingSystemName(this.s.numberingSystem), eid: 'settings_numbering_system', summaryId: 'settings_numbering_system_summary', onTap: () => { this.dialog = 2; } })
              SettingRow({ symbol: $r('sys.symbol.waveform'), title: $r('app.string.settings_vibration_title'), summary: $r('app.string.settings_vibration_desc'), hasSwitch: true, isOn: this.s.vibrationMode, eid: 'settings_vibration_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.vibrationMode = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.timer'), title: $r('app.string.settings_radians_title'), summary: $r('app.string.settings_radians_desc'), hasSwitch: true, isOn: this.s.useRadiansByDefault, eid: 'settings_radians_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.useRadiansByDefault = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.calculator'), title: $r('app.string.settings_scientific_title'), summary: $r('app.string.settings_scientific_desc'), hasSwitch: true, isOn: this.s.scientificModeByDefault, eid: 'settings_scientific_mode_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.scientificModeByDefault = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.square_grid_2x2'), title: $r('app.string.settings_split_title'), summary: $r('app.string.settings_split_desc'), hasSwitch: true, isOn: this.s.splitParenthesisButton, eid: 'settings_split_parenthesis_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.splitParenthesisButton = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.minus_circle'), title: $r('app.string.settings_modulo_title'), summary: $r('app.string.settings_modulo_desc'), hasSwitch: true, isOn: this.s.addModuloButton, eid: 'settings_modulo_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.addModuloButton = v; }); } })
              SettingHeader({ title: $r('app.string.settings_formatting') })
              SettingRow({ symbol: $r('sys.symbol.textformat'), title: $r('app.string.settings_precision_title'), summary: this.store.precisionLabel(this.s.numberPrecision), eid: 'settings_precision', summaryId: 'settings_precision_summary', onTap: () => { this.dialog = 3; } })
              SettingRow({ symbol: $r('sys.symbol.flame'), title: $r('app.string.settings_sci_notation_title'), summary: $r('app.string.settings_sci_notation_desc'), hasSwitch: true, isOn: this.s.numberIntoScientificNotation, eid: 'settings_scientific_notation_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.numberIntoScientificNotation = v; }); } })
              SettingHeader({ title: $r('app.string.settings_history') })
              SettingRow({ symbol: $r('sys.symbol.arrow_counterclockwise_clock'), title: $r('app.string.settings_history_size_title'), summary: this.store.historySizeLabel(this.s.historySize), eid: 'settings_history_size', summaryId: 'settings_history_size_summary', onTap: () => { this.dialog = 4; } })
              SettingRow({ symbol: $r('sys.symbol.trash'), title: $r('app.string.settings_swipe_title'), summary: $r('app.string.settings_swipe_desc'), hasSwitch: true, isOn: this.s.deleteHistoryOnSwipe, eid: 'settings_delete_on_swipe_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.deleteHistoryOnSwipe = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.save'), title: $r('app.string.settings_autosave_title'), summary: $r('app.string.settings_autosave_desc'), hasSwitch: true, isOn: this.s.autoSaveCalculationWithoutEqualButton, eid: 'settings_auto_save_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.autoSaveCalculationWithoutEqualButton = v; }); } })
              SettingHeader({ title: $r('app.string.settings_advanced') })
              SettingRow({ symbol: $r('sys.symbol.paperclip'), title: $r('app.string.settings_longpress_title'), summary: $r('app.string.settings_longpress_desc'), hasSwitch: true, isOn: this.s.longClickToCopyValue, eid: 'settings_long_click_copy_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.longClickToCopyValue = v; }); } })
              SettingRow({ symbol: $r('sys.symbol.sun_max'), title: $r('app.string.settings_awake_title'), summary: $r('app.string.settings_awake_desc'), hasSwitch: true, isOn: this.s.preventPhoneFromSleepingMode, eid: 'settings_prevent_sleep_switch', onChange: (v: boolean) => { this.change((n: CalcSettings) => { n.preventPhoneFromSleepingMode = v; }); } })
            }
            .width('100%')
          }
          .align(Alignment.Top)
          .layoutWeight(1)
          .width('100%')
          .id('settings_list')
        }
        .width('100%')
        .height('100%')

        if (this.dialog !== 0) {
          Column() {
            Column() {
              Scroll() {
                Column() {
                  ForEach(this.options(), (o: Opt) => {
                    ChoiceRow({ title: o.label, selected: o.value === this.selected(), eid: `settings_option_${o.value}`, onTap: () => { this.pick(o.value); } })
                  }, (o: Opt) => `${this.dialog}_${o.value}_${o.value === this.selected()}`)
                }
              }
              .align(Alignment.Top)
            }
            .width('85%')
            .constraintSize({ maxHeight: '70%' })
            .padding(Space.s)
            .backgroundColor(AppColors.surface)
            .borderRadius(Radius.l)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.scrim)
          .onClick(() => { this.dialog = 0; })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.background)
    }
    .hideTitleBar(true)
    .onShown(() => { this.reload(); })
    .id('page_Settings')
  }
}
