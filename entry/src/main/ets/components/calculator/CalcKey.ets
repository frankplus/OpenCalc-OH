import { AppColors, Size, Type } from '../../theme/Theme';

// One calculator key. kind: 0 digit, 1 operator, 2 clear, 3 equals, 4 flat (no background).
// The cell takes the row's weight; the key inside is a circle (basic) or a pill (pill = true).
@ComponentV2
export struct CalcKey {
  @Param label: ResourceStr = '';
  @Param symbol: Resource | undefined = undefined;
  @Param eid: string = '';
  @Param kind: number = 0;
  @Param keyHeight: number = 64;
  @Consumer('calcPill') pill: boolean = false;
  @Consumer('calcAmoled') amoled: boolean = false;
  @Param zeroMenu: boolean = false;
  @Event onTap: () => void = () => {};
  @Event onLong: () => void = () => {};
  @Event onInsert: (value: string) => void = () => {};

  private fill(): ResourceColor {
    if (this.kind === 4) {
      return Color.Transparent;
    }
    if (this.amoled) {
      return $r('app.color.calculator_amoled');
    }
    if (this.kind === 0) {
      return $r('app.color.calculator_key_digit');
    } else if (this.kind === 1) {
      return $r('app.color.calculator_key_op');
    } else if (this.kind === 2) {
      return $r('app.color.calculator_key_clear');
    }
    return $r('app.color.calculator_key_equals');
  }

  @Builder
  insertMenu() {
    Menu() {
      MenuItem({ content: '00' }).onClick(() => { this.onInsert('00'); })
      MenuItem({ content: '000' }).onClick(() => { this.onInsert('000'); })
    }
  }

  build() {
    Row() {
      if (this.symbol !== undefined) {
        Column() {
          SymbolGlyph(this.symbol).fontSize(Size.icon).fontColor([AppColors.textPrimary])
        }
        .id(this.eid)
        .width(this.pill ? '92%' : this.keyHeight)
        .height(this.keyHeight)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.fill())
        .borderRadius(this.keyHeight / 2)
        .onClick(() => { this.onTap(); })
        .gesture(LongPressGesture().onAction(() => { this.onLong(); }))
      } else {
        Button(this.label, { type: ButtonType.Normal, stateEffect: true })
          .id(this.eid)
          .fontSize(this.kind === 4 ? Type.subtitle : Type.title)
          .fontColor(AppColors.textPrimary)
          .backgroundColor(this.fill())
          .borderRadius(this.keyHeight / 2)
          .width(this.pill || this.kind === 4 ? '92%' : this.keyHeight)
          .height(this.keyHeight)
          .padding(0)
          .onClick(() => { this.onTap(); })
          .gesture(LongPressGesture().onAction(() => { this.onLong(); }))
      }
    }
    .layoutWeight(1)
    .height(this.keyHeight + 8)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .bindContextMenu(this.zeroMenu ? this.insertMenu : undefined, ResponseType.LongPress)
  }
}
