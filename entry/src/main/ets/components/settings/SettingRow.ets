import { AppColors, Size, Space, Type } from '../../theme/Theme';

@ComponentV2
export struct SettingHeader {
  @Param title: ResourceStr = '';

  build() {
    Text(this.title)
      .fontSize(Type.secondary)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.settings_header'))
      .width('100%')
      .padding({ left: Space.l, right: Space.l, top: Space.l, bottom: Space.xs })
  }
}

@ComponentV2
export struct SettingRow {
  @Param symbol: Resource = $r('sys.symbol.gearshape');
  @Param title: ResourceStr = '';
  @Param summary: ResourceStr = '';
  @Param eid: string = '';
  @Param summaryId: string = '';
  @Param hasSwitch: boolean = false;
  @Param isOn: boolean = false;
  @Event onTap: () => void = () => {};
  @Event onChange: (isOn: boolean) => void = (isOn: boolean) => {};

  build() {
    Row({ space: Space.l }) {
      SymbolGlyph(this.symbol)
        .fontSize(Size.icon)
        .fontColor([AppColors.icon])
        .width(Size.icon)
      Column({ space: Space.xs }) {
        Text(this.title)
          .fontSize(Type.body)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .width('100%')
        Text(this.summary)
          .fontSize(Type.secondary)
          .fontColor(AppColors.textSecondary)
          .width('100%')
          .constraintSize({ minHeight: 20 })
          .id(this.summaryId)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (this.hasSwitch) {
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .id(this.eid)
          .onChange((v: boolean) => { this.onChange(v); })
      }
    }
    .width('100%')
    .constraintSize({ minHeight: Size.row })
    .padding({ left: Space.l, right: Space.l, top: Space.s, bottom: Space.s })
    .alignItems(VerticalAlign.Center)
    .id(this.hasSwitch ? '' : this.eid)
    .onClick(() => { this.onTap(); })
  }
}
