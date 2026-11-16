// Entity "CalcResult" from the AppSpec (persistence: memory). Generated shape; the data work item may extend it,
// keeping CalcResultData, toJSON and fromJSON in step with the fields.

/** CalcResult as plain data: what goes to storage and comes back from it. */
export interface CalcResultData {
  ok: boolean;
  value: string;
  error: string;
}

@ObservedV2
export class CalcResult {
  @Trace ok: boolean = true;
  @Trace value: string = '';
  @Trace error: string = '';

  /**
   * JSON.stringify calls this, for one entity or a list of them. Without it the fields are written under internal
   * names (__ob_<field>) and nothing reads back.
   */
  toJSON(): CalcResultData {
    return {
      ok: this.ok,
      value: this.value,
      error: this.error,
    };
  }

  /** An entity from data read back: (JSON.parse(raw) as CalcResultData[]).map((d: CalcResultData) => CalcResult.fromJSON(d)). A field the data lacks keeps its initial value. */
  static fromJSON(d: CalcResultData): CalcResult {
    const item = new CalcResult();
    if (d.ok !== undefined) {
      item.ok = d.ok;
    }
    if (d.value !== undefined) {
      item.value = d.value;
    }
    if (d.error !== undefined) {
      item.error = d.error;
    }
    return item;
  }
}
