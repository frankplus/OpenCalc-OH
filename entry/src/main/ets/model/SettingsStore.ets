// The data layer's contract, from the AppSpec: The CalcSettings in one preferences file with the original's defaults, cached for synchronous reads.
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { i18n } from '@kit.LocalizationKit';
import { CalcSettings } from './CalcSettings';

const TAG: string = 'SettingsStore';

export class SettingsStore {
  private static instance: SettingsStore | null = null;
  private prefs: preferences.Preferences | null = null;
  private context: common.Context | null = null;
  private cache: CalcSettings = new CalcSettings();

  static getInstance(): SettingsStore {
    if (SettingsStore.instance === null) {
      SettingsStore.instance = new SettingsStore();
    }
    return SettingsStore.instance;
  }

  /** Opens the preferences file and loads the settings; a second call does nothing. */
  async init(context: common.Context): Promise<void> {
    if (this.prefs !== null) {
      return;
    }
    try {
      this.context = context;
      this.prefs = preferences.getPreferencesSync(context, { name: 'opencalc_settings' });
      this.cache = this.readAll();
    } catch (e) {
      this.prefs = null;
      hilog.error(0x0001, TAG, 'init failed: %{public}s', JSON.stringify(e));
    }
  }

  private open(): preferences.Preferences {
    if (this.prefs === null) {
      hilog.error(0x0001, TAG, 'storage is not open');
      throw new Error('Settings storage is not open');
    }
    return this.prefs;
  }

  private readAll(): CalcSettings {
    const p = this.open();
    const s = new CalcSettings();
    s.themeStyle = p.getSync('themeStyle', s.themeStyle) as number;
    s.vibrationMode = p.getSync('vibrationMode', s.vibrationMode) as boolean;
    s.useRadiansByDefault = p.getSync('useRadiansByDefault', s.useRadiansByDefault) as boolean;
    s.scientificModeByDefault = p.getSync('scientificModeByDefault', s.scientificModeByDefault) as boolean;
    s.splitParenthesisButton = p.getSync('splitParenthesisButton', s.splitParenthesisButton) as boolean;
    s.addModuloButton = p.getSync('addModuloButton', s.addModuloButton) as boolean;
    s.numberPrecision = p.getSync('numberPrecision', s.numberPrecision) as number;
    s.numberIntoScientificNotation =
      p.getSync('numberIntoScientificNotation', s.numberIntoScientificNotation) as boolean;
    s.historySize = p.getSync('historySize', s.historySize) as number;
    s.deleteHistoryOnSwipe = p.getSync('deleteHistoryOnSwipe', s.deleteHistoryOnSwipe) as boolean;
    s.autoSaveCalculationWithoutEqualButton =
      p.getSync('autoSaveCalculationWithoutEqualButton', s.autoSaveCalculationWithoutEqualButton) as boolean;
    s.longClickToCopyValue = p.getSync('longClickToCopyValue', s.longClickToCopyValue) as boolean;
    s.preventPhoneFromSleepingMode =
      p.getSync('preventPhoneFromSleepingMode', s.preventPhoneFromSleepingMode) as boolean;
    s.numberingSystem = p.getSync('numberingSystem', s.numberingSystem) as number;
    return s;
  }

  async load(): Promise<CalcSettings> {
    try {
      this.cache = this.readAll();
    } catch (e) {
      hilog.error(0x0001, TAG, 'load failed: %{public}s', JSON.stringify(e));
      throw e as Error;
    }
    return this.cache;
  }

  current(): CalcSettings {
    return this.cache;
  }

  async save(settings: CalcSettings): Promise<void> {
    const p = this.open();
    try {
      p.putSync('themeStyle', settings.themeStyle);
      p.putSync('vibrationMode', settings.vibrationMode);
      p.putSync('useRadiansByDefault', settings.useRadiansByDefault);
      p.putSync('scientificModeByDefault', settings.scientificModeByDefault);
      p.putSync('splitParenthesisButton', settings.splitParenthesisButton);
      p.putSync('addModuloButton', settings.addModuloButton);
      p.putSync('numberPrecision', settings.numberPrecision);
      p.putSync('numberIntoScientificNotation', settings.numberIntoScientificNotation);
      p.putSync('historySize', settings.historySize);
      p.putSync('deleteHistoryOnSwipe', settings.deleteHistoryOnSwipe);
      p.putSync('autoSaveCalculationWithoutEqualButton', settings.autoSaveCalculationWithoutEqualButton);
      p.putSync('longClickToCopyValue', settings.longClickToCopyValue);
      p.putSync('preventPhoneFromSleepingMode', settings.preventPhoneFromSleepingMode);
      p.putSync('numberingSystem', settings.numberingSystem);
      await p.flush();
      this.cache = CalcSettings.fromJSON(settings.toJSON());
    } catch (e) {
      hilog.error(0x0001, TAG, 'save failed: %{public}s', JSON.stringify(e));
      throw e as Error;
    }
  }

  applyTheme(themeStyle: number): void {
    try {
      if (this.context === null) {
        return;
      }
      let mode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
      if (themeStyle === 1) {
        mode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      } else if (themeStyle === 2 || themeStyle === 3) {
        mode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      }
      this.context.getApplicationContext().setColorMode(mode);
    } catch (e) {
      hilog.error(0x0001, TAG, 'applyTheme failed: %{public}s', JSON.stringify(e));
    }
  }

  themeName(themeStyle: number): Resource {
    switch (themeStyle) {
      case 1:
        return $r('app.string.SettingsStore_theme_light');
      case 2:
        return $r('app.string.SettingsStore_theme_dark');
      case 3:
        return $r('app.string.SettingsStore_theme_amoled');
      default:
        return $r('app.string.SettingsStore_theme_system');
    }
  }

  numberingSystemName(numberingSystem: number): Resource {
    if (numberingSystem === 1) {
      return $r('app.string.SettingsStore_numbering_indian');
    }
    return $r('app.string.SettingsStore_numbering_international');
  }

  precisionOptions(): number[] {
    const out: number[] = [];
    for (let i = 0; i <= 20; i++) {
      out.push(i);
    }
    out.push(25, 30, 40, 50, 75, 100, 1000);
    return out;
  }

  precisionLabel(precision: number): string {
    return precision === 1000 ? '∞' : precision.toString();
  }

  historySizeOptions(): number[] {
    return [0, 10, 20, 50, 100, 200, 500, 1000, -1];
  }

  historySizeLabel(historySize: number): string {
    return historySize === -1 ? '∞' : historySize.toString();
  }

  languageName(): string {
    try {
      const lang = i18n.System.getSystemLanguage();
      return i18n.System.getDisplayLanguage(lang, lang, true);
    } catch (e) {
      hilog.error(0x0001, TAG, 'languageName failed: %{public}s', JSON.stringify(e));
      return '';
    }
  }
}
