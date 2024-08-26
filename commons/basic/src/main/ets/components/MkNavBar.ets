import { router } from '@kit.ArkUI'

@Component
export struct MkNavbar {
  // 顶部安全区域
  @StorageProp('safeTop') safeTop: number = 0
  // 标题
  @Prop
  title: string = ''
  // 左侧图标
  @Prop
  leftIcon: ResourceStr = $r('app.media.ic_public_left')
  // 右侧图标
  @Prop
  rightIcon: ResourceStr = $r('app.media.ic_public_more')
  // 是否显示左侧图标
  @Prop
  showLeftIcon: boolean = true
  // 是否显示右侧图标
  @Prop
  showRightIcon: boolean = false
  // 文字+图标颜色
  @Prop
  color: ResourceColor = $r('app.color.black')
  // 背景色
  @Prop
  bg: ResourceColor = $r('app.color.white')
  // 左侧点击事件
  leftClickHandler = () => {
  }
  // 右侧点击事件
  rightClickHandler = () => {
  }

  @Builder
  defaultTitle() {
    Text(this.title)
      .fontSize(16)
      .fontWeight(500)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .fontColor(this.color)
  }

  @BuilderParam
  customTitle: () => void = this.defaultTitle

  build() {
    Row() {
      Row() {
        if (this.showLeftIcon) {
          Image(this.leftIcon)
            .width(24)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(() => {
              this.leftClickHandler()
            })
        }

      }
      .width(50)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)

      this.customTitle()

      Row() {
        if (this.showRightIcon) {
          Image(this.rightIcon)
            .width(24)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(() => {
              this.rightClickHandler()
            })
        }
      }
      .width(50)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(50 + this.safeTop)
    .backgroundColor(this.bg)
    .padding({ top: this.safeTop })
  }
}