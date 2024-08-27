import { MkGoodsItem, MkGuess, MkNavbar, HmSku, MKDialogLoading } from '@mk/basic'
import { Goods } from '../viewmodel'
import { window } from '@kit.ArkUI'

@Builder
function GoodsViewBuilder() {
  GoodsView()
}

@Component
export struct GoodsView {
  @StorageProp('safeBottom')
  safeBottom: number = 0
  @State
  goods: Goods = {} as Goods
  @State
  activeIndex: number = 0
  @State
  showSheet: boolean = false
  @State
  count: number = 1
  @State
  loading: boolean = false
  @State
  sku: HmSku = {} as HmSku
  scroller = new Scroller()
  @Consume
  pathStack: NavPathStack
  tabs: string[] = ['商品', '评价', '详情', '推荐']
  // 自定义弹窗
  dialog: CustomDialogController = new CustomDialogController({
    builder: MKDialogLoading({ message: '拼命加载中' }),
    customStyle: true, // 设置为自定义样式
    alignment: DialogAlignment.Center // 显示方式为居中
  })

  setStatusBar() {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#000000' })
      })
  }

  async aboutToAppear() {
    // 接收并解析数据
    this.setStatusBar()
  }

  @Builder
  tabBuilder(item: string, index: number) {

  }

  @Builder
  CustomTitleBuilder() {
    Tabs({ index: this.activeIndex }) {
      ForEach(this.tabs, (item: string, index: number) => {
        TabContent() {
        }
        .tabBar(this.tabBuilder(item, index))
      })
    }
    .width(150)
    .onTabBarClick(index => this.activeIndex = index)

    Blank()
    // 楼层切换
    Image($r('[basic].media.ic_public_shared'))
      .iconButton()
  }

  @Builder
  AddCartBuilder() {
    Column() {
      Text('已选: ' + '')
        .fontWeight(300)
        .width('100%')
        .fontColor($r('[basic].color.black'))
        .fontSize(14)
        .padding({ bottom: 10, right: 50 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 10 }) {
        Image(this.goods.mainPictures?.[0])
          .alt($r('app.media.ic_sku_img'))
          .width(80)
          .height(80)
          .backgroundColor($r('[basic].color.under'))
          .borderRadius(4)
        Column() {
          Row() {
            Text('现价¥')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .offset({ y: -4 })
            Text(this.goods.price)
              .fontSize(24)
              .fontColor($r('[basic].color.black'))
              .fontWeight(500)
            Text('原价¥' + (this.goods.price))
              .fontSize(12)
              .fontColor($r('[basic].color.gray'))
              .margin({ left: 10 })
              .offset({ y: -4 })
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('[basic].color.gray')
              })
          }
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 10 }) {
            // 计数器

            Text(`库存充足`)
              .fontSize(12)
              .fontColor($r('[basic].color.gray'))
          }
        }
        .height(80)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Divider()
        .strokeWidth(4)
        .color($r('[basic].color.under'))
        .margin({ left: -8, right: -8, top: 13 })

      List() {
        ListItem() {
          // Sku 组件
          //  MKSku({
          //   specs: this.goods.specs,
          //   skus: this.goods.skus,
          //   onSkuChange: (sku: HmSku) => {
          //     this.sku = sku
          //   }
          // })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Button(this.loading ? '加入中...' : '加入购物袋')
          .buyButton($r('[basic].color.black'), true)
          .onClick(() => {
          })
        Button('立即购买')
          .buyButton($r('[basic].color.red'), false)
      }
      .width('100%')
    }
    .height(600)
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.safeBottom || 16
    })
  }

  build() {
    NavDestination() {
      Column() {
        MkNavbar({
          showRightIcon: true,
          customTitle: () => {
            this.CustomTitleBuilder()
          }
        })
        Column() {
          List({ scroller: this.scroller }) {
            ListItem() {
              // 商品信息
              GoodsInfoComp({ goods: this.goods, showSheet: this.showSheet })
            }

            ListItem() {
              // 评论 目前无评论数据
              GoodsCommentComp({ goods: this.goods })
            }

            ListItem() {
              // 商品详情
              GoodsDetailComp({ goods: this.goods })
            }

            ListItem() {
              // 猜你喜欢
              MkGuess()
            }
          }
          .onScrollIndex((index) => {
            this.activeIndex = index
          })
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
        }
        .layoutWeight(1)
        .backgroundColor($r('[basic].color.under'))

        Row() {
          Image($r('[basic].media.ic_public_like'))
            .iconButton()
          Image($r('[basic].media.ic_public_comment'))
            .iconButton()
          Badge({
            count: 10,
            style: {},
            position: { x: 30, y: 4 }
          }) {
            Image($r('[basic].media.ic_public_cart'))
              .iconButton()
              .onClick(() => {

              })
          }

          Row() {
            Button('加入购物袋')
              .buyButton($r('[basic].color.black'), true)
              .onClick(() => this.showSheet = true)
            Button('立即购买')
              .buyButton($r('[basic].color.red'), false)
              .onClick(() => this.showSheet = true)
          }
          .layoutWeight(1)
          .padding({ right: 16, left: 6 })
        }
        .height(54)
        .width('100%')
        .margin({ bottom: this.safeBottom })
      }
      .height('100%')
      .bindSheet($$this.showSheet, this.AddCartBuilder(),
        { height: SheetSize.FIT_CONTENT, backgroundColor: $r('[basic].color.white') })
    }
    .hideTitleBar(true)
  }
}

@Extend(Image)
function iconButton() {
  .width(24)
  .aspectRatio(1)
  .margin(13)
  .fillColor($r('[basic].color.black'))
}

@Extend(Button)
function buyButton(color: ResourceStr, isLeft: boolean) {
  .fontSize(14)
  .height(36)
  .type(ButtonType.Normal)
  .layoutWeight(1)
  .backgroundColor(color)
  .borderRadius({
    topLeft: isLeft ? 18 : 0,
    bottomLeft: isLeft ? 18 : 0,
    topRight: isLeft ? 0 : 18,
    bottomRight: isLeft ? 0 : 18
  })
  .pixelRound({
    end: PixelRoundCalcPolicy.FORCE_CEIL,
    start: PixelRoundCalcPolicy.FORCE_FLOOR
  })
}

@Component
struct GoodsInfoComp {
  @Prop goods: Goods = {} as Goods
  @Link showSheet: boolean

  build() {
    Column() {
      // 有 多张图片显示轮播图
      if (this.goods.mainPictures && this.goods.mainPictures.length) {
        Swiper() {
          ForEach(this.goods.mainPictures, (src: string) => {
            Image(src)
          })
        }
        .cachedCount(5)
        .indicator(Indicator.digit()
          .right(10)
          .bottom(6))
        .width('100%')
        .aspectRatio(1)
      } else {
        // 没有展示主图片
        Image(this.goods.picture)
          .width('100%')
          .aspectRatio(1)
      }

      Column() {
        Text() {
          Span('¥ ')
          Span(this.goods.price)
            .fontSize(24)
        }
        .width('100%')
        .fontWeight(500)
        .fontColor($r('[basic].color.black'))
        .margin({ bottom: 8, top: 8 })

        Text(this.goods.name)
          .width('100%')
          .fontColor($r('[basic].color.text'))
          .margin({ bottom: 8 })
        Text(this.goods.desc)
          .fontSize(13)
          .width('100%')
          .fontColor($r('[basic].color.gray'))
          .margin({ bottom: 8 })

        Column() {
          Row({ space: 8 }) {
            Text('商品规格')
              .fontSize(13)
              .fontWeight(500)
              .fontColor($r('[basic].color.black'))
            Text('请选择')
              .fontSize(13)
              .fontColor($r('[basic].color.gray'))
            Blank()
            Image($r('[basic].media.ic_public_right'))
              .width(20)
              .aspectRatio(1)
              .fillColor($r('[basic].color.gray'))
          }
          .width('100%')
          .height(40)
          .onClick(() => this.showSheet = true)

          Row() {
            Text('无忧退货 · 快速退款 · 免费包邮')
              .fontColor($r('[basic].color.text'))
              .fontSize(13)
            Blank()
            Image($r('[basic].media.ic_public_right'))
              .width(20)
              .aspectRatio(1)
              .fillColor($r('[basic].color.gray'))
          }
          .width('100%')
          .height(40)
          .border({
            width: { top: 0.5 },
            color: $r('[basic].color.under')
          })
        }
      }
      .backgroundColor($r('[basic].color.white'))
      .borderRadius(8)
      .margin(8)
      .padding(8)
    }
  }
}

@Component
struct GoodsCommentComp {
  goods: MkGoodsItem = {} as MkGoodsItem

  build() {
    Column() {
      Row() {
        Text('商品评价')
          .fontSize(13)
          .fontWeight(700)
          .fontColor($r('[basic].color.black'))
          .margin({ right: 8 })
        Text('(100+)')
          .fontSize(13)
          .fontColor($r('[basic].color.gray'))
        Blank()
        Text('查看全部')
          .fontSize(13)
          .fontColor($r('[basic].color.gray'))
        Image($r('[basic].media.ic_public_right'))
          .width(20)
          .aspectRatio(1)
          .fillColor($r('[basic].color.gray'))
      }
      .width('100%')
      .height(40)

      ForEach(new Array(2).fill(0), () => {
        Column({ space: 8 }) {
          Row() {
            Image($r('app.media.goods_avatar'))
              .width(24)
              .aspectRatio(1)
              .margin({ right: 8 })
            Text('匿名用户1259')
              .fontColor($r('[basic].color.black'))
              .fontSize(14)
          }
          .width('100%')

          Row() {
            Text('黑色·公开版·128G')
              .fontColor($r('[basic].color.gray'))
              .fontSize(12)
            Blank()
            Text('昨天23.45')
              .fontColor($r('[basic].color.gray'))
              .fontSize(12)
          }
          .width('100%')

          Text('HUAWEI Pura 70 Ultra 创新性采用超聚光伸缩主摄，搭载1英寸大底传感器、以及1英寸传感器中最大的F1.6物理光圈，带来业界最大的主摄进光量。')
            .fontColor($r('[basic].color.text'))
            .fontSize(13)

          Row({ space: 8 }) {
            ForEach(new Array(3).fill(0), () => {
              Image(this.goods.picture)
                .width(80)
                .aspectRatio(1)
            })
          }
          .width('100%')
        }
        .margin({ top: 16 })
      })
    }
    .backgroundColor($r('[basic].color.white'))
    .borderRadius(8)
    .margin({ left: 8, right: 8, bottom: 8 })
    .padding(8)
  }
}

@Component
struct GoodsDetailComp {
  @Prop goods: Goods = {} as Goods

  build() {
    Column() {
      Row() {
        Text('商品详情')
          .fontSize(13)
          .fontWeight(700)
          .fontColor($r('[basic].color.black'))
          .margin({ left: 16 })
      }
      .width('100%')
      .height(50)

      ForEach(this.goods.details?.pictures, (src: string) => {
        Image(src)
          .width('100%')
      })
    }
    .backgroundColor($r('[basic].color.white'))
    .margin({ bottom: 8 })
  }
}