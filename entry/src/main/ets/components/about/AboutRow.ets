import { AppColors, Size, Space, Type } from '../../theme/Theme';

@ComponentV2
export struct AboutRow {
  @Param symbol: Resource = $r('sys.symbol.info_circle');
  @Param label: ResourceStr = '';
  @Param eid: string = '';
  @Event onTap: () => void = () => {};

  build() {
    Row({ space: Space.l }) {
      SymbolGlyph(this.symbol)
        .fontSize(Size.icon)
        .fontColor([AppColors.textPrimary])
      Text(this.label)
        .id(this.eid)
        .fontSize(Type.body)
        .fontColor(AppColors.textPrimary)
        .layoutWeight(1)
        .constraintSize({ minHeight: 24 })
    }
    .width('100%')
    .height(Size.row)
    .padding({ left: Space.l, right: Space.l })
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.onTap(); })
  }
}
