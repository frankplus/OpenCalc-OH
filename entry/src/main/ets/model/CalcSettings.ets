// Entity "CalcSettings" from the AppSpec (persistence: preferences). Generated shape; the data work item may extend it,
// keeping CalcSettingsData, toJSON and fromJSON in step with the fields.

/** CalcSettings as plain data: what goes to storage and comes back from it. */
export interface CalcSettingsData {
  themeStyle: number;
  vibrationMode: boolean;
  useRadiansByDefault: boolean;
  scientificModeByDefault: boolean;
  splitParenthesisButton: boolean;
  addModuloButton: boolean;
  numberPrecision: number;
  numberIntoScientificNotation: boolean;
  historySize: number;
  deleteHistoryOnSwipe: boolean;
  autoSaveCalculationWithoutEqualButton: boolean;
  longClickToCopyValue: boolean;
  preventPhoneFromSleepingMode: boolean;
  numberingSystem: number;
}

@ObservedV2
export class CalcSettings {
  @Trace themeStyle: number = 0;
  @Trace vibrationMode: boolean = true;
  @Trace useRadiansByDefault: boolean = false;
  @Trace scientificModeByDefault: boolean = false;
  @Trace splitParenthesisButton: boolean = false;
  @Trace addModuloButton: boolean = true;
  @Trace numberPrecision: number = 10;
  @Trace numberIntoScientificNotation: boolean = false;
  @Trace historySize: number = 50;
  @Trace deleteHistoryOnSwipe: boolean = true;
  @Trace autoSaveCalculationWithoutEqualButton: boolean = true;
  @Trace longClickToCopyValue: boolean = true;
  @Trace preventPhoneFromSleepingMode: boolean = false;
  @Trace numberingSystem: number = 0;

  /**
   * JSON.stringify calls this, for one entity or a list of them. Without it the fields are written under internal
   * names (__ob_<field>) and nothing reads back.
   */
  toJSON(): CalcSettingsData {
    return {
      themeStyle: this.themeStyle,
      vibrationMode: this.vibrationMode,
      useRadiansByDefault: this.useRadiansByDefault,
      scientificModeByDefault: this.scientificModeByDefault,
      splitParenthesisButton: this.splitParenthesisButton,
      addModuloButton: this.addModuloButton,
      numberPrecision: this.numberPrecision,
      numberIntoScientificNotation: this.numberIntoScientificNotation,
      historySize: this.historySize,
      deleteHistoryOnSwipe: this.deleteHistoryOnSwipe,
      autoSaveCalculationWithoutEqualButton: this.autoSaveCalculationWithoutEqualButton,
      longClickToCopyValue: this.longClickToCopyValue,
      preventPhoneFromSleepingMode: this.preventPhoneFromSleepingMode,
      numberingSystem: this.numberingSystem,
    };
  }

  /** An entity from data read back: (JSON.parse(raw) as CalcSettingsData[]).map((d: CalcSettingsData) => CalcSettings.fromJSON(d)). A field the data lacks keeps its initial value. */
  static fromJSON(d: CalcSettingsData): CalcSettings {
    const item = new CalcSettings();
    if (d.themeStyle !== undefined) {
      item.themeStyle = d.themeStyle;
    }
    if (d.vibrationMode !== undefined) {
      item.vibrationMode = d.vibrationMode;
    }
    if (d.useRadiansByDefault !== undefined) {
      item.useRadiansByDefault = d.useRadiansByDefault;
    }
    if (d.scientificModeByDefault !== undefined) {
      item.scientificModeByDefault = d.scientificModeByDefault;
    }
    if (d.splitParenthesisButton !== undefined) {
      item.splitParenthesisButton = d.splitParenthesisButton;
    }
    if (d.addModuloButton !== undefined) {
      item.addModuloButton = d.addModuloButton;
    }
    if (d.numberPrecision !== undefined) {
      item.numberPrecision = d.numberPrecision;
    }
    if (d.numberIntoScientificNotation !== undefined) {
      item.numberIntoScientificNotation = d.numberIntoScientificNotation;
    }
    if (d.historySize !== undefined) {
      item.historySize = d.historySize;
    }
    if (d.deleteHistoryOnSwipe !== undefined) {
      item.deleteHistoryOnSwipe = d.deleteHistoryOnSwipe;
    }
    if (d.autoSaveCalculationWithoutEqualButton !== undefined) {
      item.autoSaveCalculationWithoutEqualButton = d.autoSaveCalculationWithoutEqualButton;
    }
    if (d.longClickToCopyValue !== undefined) {
      item.longClickToCopyValue = d.longClickToCopyValue;
    }
    if (d.preventPhoneFromSleepingMode !== undefined) {
      item.preventPhoneFromSleepingMode = d.preventPhoneFromSleepingMode;
    }
    if (d.numberingSystem !== undefined) {
      item.numberingSystem = d.numberingSystem;
    }
    return item;
  }
}
