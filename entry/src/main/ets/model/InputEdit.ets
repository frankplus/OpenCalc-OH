// Entity "InputEdit" from the AppSpec (persistence: memory). Generated shape; the data work item may extend it,
// keeping InputEditData, toJSON and fromJSON in step with the fields.

/** InputEdit as plain data: what goes to storage and comes back from it. */
export interface InputEditData {
  text: string;
  caret: number;
}

@ObservedV2
export class InputEdit {
  @Trace text: string = '';
  @Trace caret: number = 0;

  /**
   * JSON.stringify calls this, for one entity or a list of them. Without it the fields are written under internal
   * names (__ob_<field>) and nothing reads back.
   */
  toJSON(): InputEditData {
    return {
      text: this.text,
      caret: this.caret,
    };
  }

  /** An entity from data read back: (JSON.parse(raw) as InputEditData[]).map((d: InputEditData) => InputEdit.fromJSON(d)). A field the data lacks keeps its initial value. */
  static fromJSON(d: InputEditData): InputEdit {
    const item = new InputEdit();
    if (d.text !== undefined) {
      item.text = d.text;
    }
    if (d.caret !== undefined) {
      item.caret = d.caret;
    }
    return item;
  }
}
