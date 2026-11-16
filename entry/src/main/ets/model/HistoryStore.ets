// The data layer's contract, from the AppSpec: The saved calculations, oldest first, as one JSON array string in preferences, trimmed to the history size.
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { History, HistoryData } from './History';

const TAG: string = 'HistoryStore';
const KEY: string = 'history';

export class HistoryStore {
  private static instance: HistoryStore | null = null;
  private prefs: preferences.Preferences | null = null;
  private context: common.Context | null = null;
  private autoSaveId: string = '';

  static getInstance(): HistoryStore {
    if (HistoryStore.instance === null) {
      HistoryStore.instance = new HistoryStore();
    }
    return HistoryStore.instance;
  }

  /** Opens the preferences file; a second call does nothing. */
  async init(context: common.Context): Promise<void> {
    if (this.prefs !== null) {
      return;
    }
    try {
      this.context = context;
      this.prefs = preferences.getPreferencesSync(context, { name: 'opencalc_history' });
    } catch (e) {
      hilog.error(0x0001, TAG, 'init failed: %{public}s', JSON.stringify(e));
    }
  }

  private open(): preferences.Preferences {
    if (this.prefs === null) {
      hilog.error(0x0001, TAG, 'storage is not open');
      throw new Error('History storage is not open');
    }
    return this.prefs;
  }

  private read(): History[] {
    const prefs = this.open();
    try {
      const raw = prefs.getSync(KEY, '[]') as string;
      const parsed: Object = JSON.parse(raw) as Object;
      if (Array.isArray(parsed)) {
        return (parsed as HistoryData[]).map((d: HistoryData) => History.fromJSON(d));
      }
    } catch (e) {
      hilog.error(0x0001, TAG, 'unreadable history: %{public}s', JSON.stringify(e));
    }
    return [];
  }

  private async write(items: History[]): Promise<void> {
    const prefs = this.open();
    try {
      prefs.putSync(KEY, JSON.stringify(items));
      await prefs.flush();
    } catch (e) {
      hilog.error(0x0001, TAG, 'save failed: %{public}s', JSON.stringify(e));
      throw e as Error;
    }
  }

  private trim(items: History[], size: number): History[] {
    if (size < 0 || items.length <= size) {
      return items;
    }
    return size === 0 ? [] : items.slice(items.length - size);
  }

  private create(calculation: string, result: string): History {
    const h = new History();
    h.id = util.generateRandomUUID();
    h.calculation = calculation;
    h.result = result;
    h.time = Date.now().toString();
    return h;
  }

  /** All saved entries, oldest first. */
  async getAll(): Promise<History[]> {
    return this.read();
  }

  async addFromEquals(calculation: string, result: string, historySize: number): Promise<History | null> {
    this.autoSaveId = '';
    const items = this.read();
    if (items.length > 0 && items[items.length - 1].calculation === calculation) {
      return null;
    }
    const h = this.create(calculation, result);
    items.push(h);
    await this.write(this.trim(items, historySize));
    return h;
  }

  async autoSave(calculation: string, result: string, historySize: number): Promise<History | null> {
    const items = this.read();
    let entry: History | null = null;
    if (this.autoSaveId.length > 0) {
      for (const it of items) {
        if (it.id === this.autoSaveId) {
          entry = it;
          break;
        }
      }
    }
    if (entry !== null) {
      entry.calculation = calculation;
      entry.result = result;
      entry.time = Date.now().toString();
    } else {
      entry = this.create(calculation, result);
      items.push(entry);
      this.autoSaveId = entry.id;
    }
    await this.write(this.trim(items, historySize));
    return entry;
  }

  endAutoSave(): void {
    this.autoSaveId = '';
  }

  async remove(id: string): Promise<void> {
    const items = this.read();
    const kept = items.filter((h: History) => h.id !== id);
    if (kept.length !== items.length) {
      await this.write(kept);
    }
  }

  async clear(): Promise<void> {
    this.autoSaveId = '';
    await this.write([]);
  }

  async trimToSize(historySize: number): Promise<History[]> {
    const items = this.read();
    const kept = this.trim(items, historySize);
    if (kept.length !== items.length) {
      await this.write(kept);
    }
    return kept;
  }

  private midnight(ms: number): number {
    const d = new Date(ms);
    return new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
  }

  dateLabel(time: string): Resource {
    const ms = parseInt(time);
    const days = Math.round((this.midnight(Date.now()) - this.midnight(ms)) / 86400000);
    if (days === 0) {
      return $r('app.string.HistoryStore_today');
    }
    if (days === 1) {
      return $r('app.string.HistoryStore_yesterday');
    }
    if (days >= 2 && days <= 6) {
      return $r('app.string.HistoryStore_days_ago', days);
    }
    const d = new Date(ms);
    let month = '';
    try {
      if (this.context !== null) {
        month = this.context.resourceManager.getStringByNameSync(
          ['HistoryStore_month_1', 'HistoryStore_month_2', 'HistoryStore_month_3', 'HistoryStore_month_4',
            'HistoryStore_month_5', 'HistoryStore_month_6', 'HistoryStore_month_7', 'HistoryStore_month_8',
            'HistoryStore_month_9', 'HistoryStore_month_10', 'HistoryStore_month_11',
            'HistoryStore_month_12'][d.getMonth()]);
      }
    } catch (e) {
      hilog.error(0x0001, TAG, 'month name failed: %{public}s', JSON.stringify(e));
    }
    return $r('app.string.HistoryStore_date', month + ' ' + d.getDate());
  }

  sameDay(a: History, b: History): boolean {
    return this.midnight(parseInt(a.time)) === this.midnight(parseInt(b.time));
  }
}
