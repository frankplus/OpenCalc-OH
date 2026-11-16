import { AppColors, Size, Space, Type } from '../../theme/Theme';
import { HistoryStore } from '../../model/HistoryStore';
import { History } from '../../model/History';

// The history panel that slides down over the keypad: oldest first, scrolled to the newest.
@ComponentV2
export struct HistoryPanel {
  @Param history: History[] = [];
  @Param swipeDelete: boolean = true;
  @Event onPick: (text: string) => void = () => {};
  @Event onCopy: (text: string) => void = () => {};
  @Event onRemove: (id: string) => void = () => {};
  private store: HistoryStore = HistoryStore.getInstance();
  private scroller: Scroller = new Scroller();

  @Builder
  deleteSwipe() {
    Column() {
      SymbolGlyph($r('sys.symbol.trash')).fontSize(Size.icon).fontColor([AppColors.danger])
    }
    .width(64)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .accessibilityText($r('app.string.calculator_delete'))
  }

  build() {
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
                  .onClick(() => { this.onPick(ri.item.calculation); })
                  .gesture(LongPressGesture().onAction(() => { this.onCopy(ri.item.calculation); }))
                Text(ri.item.result)
                  .id('history_item_result')
                  .fontSize(Type.title)
                  .fontColor(AppColors.textPrimary)
                  .width('100%')
                  .textAlign(TextAlign.End)
                  .constraintSize({ minHeight: 32 })
                  .onClick(() => { this.onPick(ri.item.result); })
                  .gesture(LongPressGesture().onAction(() => { this.onCopy(ri.item.result); }))
              }
              .id(`history_item_${ri.index}`)
              .padding({ left: Space.l, right: Space.l, top: Space.s, bottom: Space.s })
            }
            .swipeAction({
              end: this.swipeDelete ? {
                builder: () => { this.deleteSwipe(); },
                onAction: () => { this.onRemove(ri.item.id); }
              } : undefined
            })
          }).key((item: History) => `${item.id}_${item.calculation}_${item.result}_${item.time}`).virtualScroll()
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
}
