import { AppColors, Radius, Size, Space, Type } from '../../theme/Theme';

// The Support Us dialog: three wide brand buttons drawn like the original's images, and Close.
@ComponentV2
export struct DonateDialog {
  @Event onOpen: (url: string) => void = () => {};
  @Event onClose: () => void = () => {};

  @Builder
  brandButton(label: Resource, id: string, bg: Resource, fg: Resource, mark: Resource, markColor: Resource, url: string) {
    Row({ space: Space.s }) {
      SymbolGlyph(mark).fontSize(Size.icon).fontColor([markColor])
      Text(label)
        .fontSize(Type.body)
        .fontWeight(FontWeight.Bold)
        .fontColor(fg)
        .maxLines(1)
    }
    .id(id)
    .width('100%')
    .height(Size.button)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bg)
    .borderRadius(Radius.pill)
    .onClick(() => { this.onOpen(url); })
  }

  build() {
    Column() {
      Column({ space: Space.m }) {
        Text($r('app.string.calculator_support_us'))
          .id('alertTitle')
          .fontSize(Type.subtitle)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.textPrimary)
          .width('100%')
          .constraintSize({ minHeight: 24 })
        this.brandButton($r('app.string.calculator_paypal'), 'paypalImage', $r('app.color.calculator_paypal'),
          $r('app.color.calculator_white'), $r('sys.symbol.creditcard'), $r('app.color.calculator_white'),
          'https://www.paypal.me/ImDarkempire')
        this.brandButton($r('app.string.calculator_bmac'), 'bmacImage', $r('app.color.calculator_bmac'),
          $r('app.color.calculator_black'), $r('sys.symbol.cup'), $r('app.color.calculator_black'),
          'https://www.buymeacoffee.com/darkempire78')
        this.brandButton($r('app.string.calculator_github'), 'githubImage', $r('app.color.calculator_github'),
          $r('app.color.calculator_white'), $r('sys.symbol.heart_fill'), $r('app.color.calculator_heart'),
          'https://github.com/sponsors/Darkempire78')
        Row() {
          Blank()
          Button($r('app.string.calculator_close'), { type: ButtonType.Capsule })
            .id('button1')
            .height(Size.tap)
            .padding({ left: Space.m, right: Space.m })
            .fontSize(Type.body)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.calculator_accent_text'))
            .backgroundColor(Color.Transparent)
            .onClick(() => { this.onClose(); })
        }.width('100%')
      }
      .width('86%')
      .padding(Space.l)
      .backgroundColor(AppColors.surface)
      .borderRadius(Radius.l)
      .onClick(() => {})
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.scrim)
    .onClick(() => { this.onClose(); })
  }
}
