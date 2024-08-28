import { BreakpointConstants, CategoryItem, CategoryItemChild, MkNavbar } from '@mk/basic'

@Component
export struct CategoryView {
  //  Mock分类数据
  @StorageProp('categoryData')
  categories: CategoryItem[] = []
  @State activeIndex: number = 0
  // 通过 AppStorage 获取断点值
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY)
  currentBreakpoint: string = BreakpointConstants.SM
  @Consume
  pathStack: NavPathStack

  build() {
    Navigation(this.pathStack) {
      Column() {
        MkNavbar({
          title: '分类',
          showLeftIcon: false,
          showRightIcon: true,
          rightIcon: $r('[basic].media.ic_public_search'),
          rightClickHandler: () => {
            this.pathStack.pushPathByName('SearchView', null)
          }
        })
          .border({ width: { bottom: 0.5 }, color: $r('[basic].color.under') })

        Row() {
          Column() {
            ForEach(this.categories, (item: CategoryItem, i) => {
              Text(item.name)// 文本
                .backgroundColor(this.activeIndex === i ? $r('[basic].color.black') : $r('[basic].color.white'))
                .fontSize(14)
                .fontColor(this.activeIndex === i ? $r('[basic].color.white') : $r('[basic].color.black'))
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(56)
                .onClick(() => {
                  this.activeIndex = i
                })
            })
          }
          .width(88)
          .border({ width: { right: 0.5 }, color: $r('[basic].color.under') })

          Scroll() {
            Column() {
              // 顶部图片
              Image(this.categories[this.activeIndex]?.picture)
                .width('100%')
                .height(this.currentBreakpoint === BreakpointConstants.SM ? 136 : 316)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
                .margin({ bottom: 8 })
              GridRow({
                columns: {
                  sm: 2,
                  md: 3,
                  lg: 4
                }, gutter: 8
              }) {
                // 子分类
                ForEach(this.categories[this.activeIndex].children, (sub: CategoryItemChild) => {
                  GridCol() {
                    Column() {
                      // 图片
                      Image(sub?.picture)
                        .width(64)
                        .aspectRatio(1)
                      Text(sub?.name)// 文本
                        .fontSize(14)
                        .fontColor($r('[basic].color.text'))
                        .margin({ top: 8 })
                    }
                    .height('100%')
                    .justifyContent(FlexAlign.Center)
                  }
                  .aspectRatio(1)
                  .backgroundColor('#f6f6f6')
                  .borderRadius(8)
                })
              }
            }
            .padding(8)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
  }
}