import { AppColors, Type } from '../../theme/Theme';

// One calculator key. kind: 0 digit, 1 operator, 2 clear, 3 equals, 4 flat (no background).
@ComponentV2
export struct CalcKey {
  @Param label: ResourceStr = '';
  @Param symbol: Resource | undefined = undefined;
  @Param eid: string = '';
  @Param kind: number = 0;
  @Param keyHeight: number = 64;
  @Event onTap: () => void = () => {};
  @Event onLong: () => void = () => {};

  private fill(): ResourceColor {
    if (this.kind === 0) {
      return $r('app.color.calculator_key_digit');
    } else if (this.kind === 1) {
      return $r('app.color.calculator_key_op');
    } else if (this.kind === 2) {
      return $r('app.color.calculator_key_clear');
    } else if (this.kind === 3) {
      return $r('app.color.calculator_key_equals');
    }
    return Color.Transparent;
  }

  build() {
    Column() {
      if (this.symbol !== undefined) {
        SymbolGlyph(this.symbol).fontSize(24).fontColor([AppColors.textPrimary])
      } else {
        Text(this.label)
          .fontSize(this.kind === 4 ? Type.subtitle : Type.title)
          .fontColor(AppColors.textPrimary)
          .maxLines(1)
      }
    }
    .layoutWeight(1)
    .height(this.keyHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.fill())
    .borderRadius(this.keyHeight / 2)
    .margin(2)
    .id(this.eid)
    .onClick(() => { this.onTap(); })
    .gesture(LongPressGesture().onAction(() => { this.onLong(); }))
  }
}
