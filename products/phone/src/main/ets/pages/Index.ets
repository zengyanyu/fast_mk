import { BreakpointConstants, BreakPointType, Logger } from '@mk/basic'
import { CartView } from '@mk/cart'
import { CategoryView } from '@mk/category'
import { HomeView } from '@mk/home'
import { MyViews } from '@mk/my'

interface TabItem {
  text: string
  normal: ResourceStr
  active: ResourceStr
}

@Entry
@Component
struct Index {
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY)
  breakPoint: string = 'xs'
  @State
  activeIndex: number = 0
  @StorageProp('safeBottom')
  safeBottom: number = 0
  list: TabItem[] = [
    {
      text: '首页',
      normal: $r('app.media.ic_public_home_normal'),
      active: $r('app.media.ic_public_home_active')
    },
    {
      text: '分类',
      normal: $r('app.media.ic_public_pro_normal'),
      active: $r('app.media.ic_public_pro_active')
    },
    {
      text: '购物袋',
      normal: $r('app.media.ic_public_cart_normal'),
      active: $r('app.media.ic_public_cart_active')
    },
    {
      text: '我的',
      normal: $r('app.media.ic_public_my_normal'),
      active: $r('app.media.ic_public_my_active')
    },
  ]

  aboutToAppear(): void {
    Logger.info({
      "name": '曾衍育',
      "value": '曾衍育',
      "age": '30',
    })
  }

  build() {
    Tabs() {
      ForEach(this.list, (item: TabItem, index: number) => {
        TabContent() {
          if (index == 0) {
            HomeView()
          } else if (index == 1) {
            CategoryView()
          } else if (index == 2) {
            CartView()
          } else {
            MyViews()
          }
        }
        .tabBar(this.TabItemBuilder(item, index))
      })
    }
    .padding({ bottom: this.safeBottom })
    .barPosition(new BreakPointType({
      sm: BarPosition.End,
      md: BarPosition.End,
      lg: BarPosition.Start
    }).getValue(this.breakPoint))
    .vertical(this.breakPoint === BreakpointConstants.LG)
    .scrollable(false)
    .onTabBarClick(index => {
      this.activeIndex = index
    })
  }

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Column() {
      Image(this.activeIndex === index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
        .fontColor($r('[basic].color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }
}

