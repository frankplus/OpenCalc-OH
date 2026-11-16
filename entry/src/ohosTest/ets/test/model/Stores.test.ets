import { afterEach, beforeAll, describe, expect, it } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import type { common } from '@kit.AbilityKit';
import { HistoryStore } from '../../../../main/ets/model/HistoryStore';
import { SettingsStore } from '../../../../main/ets/model/SettingsStore';
import { CalcSettings } from '../../../../main/ets/model/CalcSettings';
import { History } from '../../../../main/ets/model/History';

export default function storesTest() {
  describe('HistoryStoreTest', () => {
    let context: common.Context;
    let store: HistoryStore;
    beforeAll(async () => {
      context = abilityDelegatorRegistry.getAbilityDelegator().getAppContext().getApplicationContext();
      store = new HistoryStore();
      await store.init(context);
    });
    afterEach(async () => {
      await store.clear();
    });
    it('adds_and_reads_back_oldest_first', 0, async () => {
      await store.addFromEquals('1+1', '2', 50);
      await store.addFromEquals('2+2', '4', 50);
      const all = await store.getAll();
      expect(all.length).assertEqual(2);
      expect(all[0].calculation).assertEqual('1+1');
      expect(all[1].result).assertEqual('4');
      expect(all[0].id.length).assertLarger(0);
    });
    it('same_calculation_as_last_is_not_added_twice', 0, async () => {
      await store.addFromEquals('1+1', '2', 50);
      const again = await store.addFromEquals('1+1', '2', 50);
      expect(again === null).assertTrue();
      expect((await store.getAll()).length).assertEqual(1);
    });
    it('trims_to_history_size_and_zero_keeps_nothing', 0, async () => {
      await store.addFromEquals('1+1', '2', 2);
      await store.addFromEquals('2+2', '4', 2);
      await store.addFromEquals('3+3', '6', 2);
      const all = await store.getAll();
      expect(all.length).assertEqual(2);
      expect(all[0].calculation).assertEqual('2+2');
      const left = await store.trimToSize(0);
      expect(left.length).assertEqual(0);
    });
    it('autosave_updates_one_entry_until_ended', 0, async () => {
      await store.autoSave('1', '1', 50);
      await store.autoSave('12', '12', 50);
      expect((await store.getAll()).length).assertEqual(1);
      store.endAutoSave();
      await store.autoSave('3', '3', 50);
      const all = await store.getAll();
      expect(all.length).assertEqual(2);
      expect(all[0].calculation).assertEqual('12');
    });
    it('remove_deletes_by_id_and_unknown_id_does_nothing', 0, async () => {
      const h = await store.addFromEquals('1+1', '2', 50) as History;
      await store.remove('unknown');
      expect((await store.getAll()).length).assertEqual(1);
      await store.remove(h.id);
      expect((await store.getAll()).length).assertEqual(0);
    });
    it('a_second_store_finds_what_the_first_saved', 0, async () => {
      await store.addFromEquals('4×6', '24', 50);
      const fresh = new HistoryStore();
      await fresh.init(context);
      const all = await fresh.getAll();
      expect(all.length).assertEqual(1);
      expect(all[0].calculation).assertEqual('4×6');
    });
    it('same_day_compares_calendar_days', 0, async () => {
      const a = new History();
      a.time = Date.now().toString();
      const b = new History();
      b.time = (Date.now() - 3 * 86400000).toString();
      expect(store.sameDay(a, a)).assertTrue();
      expect(store.sameDay(a, b)).assertFalse();
    });
  });

  describe('SettingsStoreTest', () => {
    let context: common.Context;
    let store: SettingsStore;
    beforeAll(async () => {
      context = abilityDelegatorRegistry.getAbilityDelegator().getAppContext().getApplicationContext();
      store = new SettingsStore();
      await store.init(context);
    });
    afterEach(async () => {
      await store.save(new CalcSettings());
    });
    it('defaults_match_the_original', 0, async () => {
      const s = await store.load();
      expect(s.numberPrecision).assertEqual(10);
      expect(s.historySize).assertEqual(50);
      expect(s.vibrationMode).assertTrue();
      expect(s.useRadiansByDefault).assertFalse();
      expect(s.addModuloButton).assertTrue();
    });
    it('save_updates_the_cache_and_a_second_store_reads_it', 0, async () => {
      const next = CalcSettings.fromJSON(store.current().toJSON());
      next.themeStyle = 2;
      next.numberingSystem = 1;
      next.historySize = -1;
      await store.save(next);
      expect(store.current().themeStyle).assertEqual(2);
      const fresh = new SettingsStore();
      await fresh.init(context);
      const s = await fresh.load();
      expect(s.themeStyle).assertEqual(2);
      expect(s.numberingSystem).assertEqual(1);
      expect(s.historySize).assertEqual(-1);
    });
    it('option_lists_and_labels', 0, () => {
      const p = store.precisionOptions();
      expect(p.length).assertEqual(28);
      expect(p[p.length - 1]).assertEqual(1000);
      expect(store.precisionLabel(1000)).assertEqual('∞');
      expect(store.precisionLabel(7)).assertEqual('7');
      const h = store.historySizeOptions();
      expect(h[0]).assertEqual(0);
      expect(h[h.length - 1]).assertEqual(-1);
      expect(store.historySizeLabel(-1)).assertEqual('∞');
      expect(store.historySizeLabel(50)).assertEqual('50');
    });
  });
}
