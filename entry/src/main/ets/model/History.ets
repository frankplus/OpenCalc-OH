// Entity "History" from the AppSpec (persistence: preferences). Generated shape; the data work item may extend it,
// keeping HistoryData, toJSON and fromJSON in step with the fields.

/** History as plain data: what goes to storage and comes back from it. */
export interface HistoryData {
  id: string;
  calculation: string;
  result: string;
  time: string;
}

@ObservedV2
export class History {
  @Trace id: string = '';
  @Trace calculation: string = '';
  @Trace result: string = '';
  @Trace time: string = '';

  /**
   * JSON.stringify calls this, for one entity or a list of them. Without it the fields are written under internal
   * names (__ob_<field>) and nothing reads back.
   */
  toJSON(): HistoryData {
    return {
      id: this.id,
      calculation: this.calculation,
      result: this.result,
      time: this.time,
    };
  }

  /** An entity from data read back: (JSON.parse(raw) as HistoryData[]).map((d: HistoryData) => History.fromJSON(d)). A field the data lacks keeps its initial value. */
  static fromJSON(d: HistoryData): History {
    const item = new History();
    if (d.id !== undefined) {
      item.id = d.id;
    }
    if (d.calculation !== undefined) {
      item.calculation = d.calculation;
    }
    if (d.result !== undefined) {
      item.result = d.result;
    }
    if (d.time !== undefined) {
      item.time = d.time;
    }
    return item;
  }
}
