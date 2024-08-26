import { BreakpointConstants, BreakPointType, MkLoading } from '@mk/basic'
import {
  getBannerApi,
  getCategoryApi,
  getHotApi,
  getNewApi,
  getOneApi,
  getPreferenceApi,
  getRecommendApi
} from '../api'
import { DiscountGoodsComp, DiscountType } from '../components/DiscountGoodsComp'
import { MkGoods } from '../components/MkGoods'
import { Banner, CategoryItem, HotResult, MKDataSource, MkGoodsItem, Params } from '../viewmodel'


@Component
export struct HomeView {
  // 轮播图
  @State banners: Banner[] = []
  // 分类
  @State categories: CategoryItem[] = []
  // 特惠推荐
  @State saleGoods: MkGoodsItem[] = []
  // 爆款推荐
  @State hotGoods: MkGoodsItem[] = []
  // 一站买全
  @State oneGoods: MkGoodsItem[] = []
  // 新鲜好物
  @State newGoods: MkGoodsItem[] = []
  // 推荐商品
  // @State recommendGoods: MkGoodsItem[] = []
  // 替换为下面
  @State recommendGoodsLazy: MKDataSource = new MKDataSource()
  // 断点值
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY)
  currentBreakpoint: string = ''
  // 顶部安全区域
  @StorageProp('safeTop')
  safeTop: number = 0
  // 记录获取的数据量
  page: number = 1
  // 加载效果
  @State isLoading: boolean = false
  // 下拉刷新
  @State refresh: boolean = false
  @Provide
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear() {
    this.getAllData()
  }

  async getAllData() {
    const proArr = [getBannerApi(), getCategoryApi(), getPreferenceApi(),
      getHotApi(), getOneApi(), getNewApi(), getRecommendApi()]
    // allSettled 可以获取到每个请求状态成功或失败
    const resArr = await Promise.allSettled(proArr)

    if (resArr[0].status == 'fulfilled') {
      this.banners = resArr[0].value.data.result as Banner[]
    }
    if (resArr[1].status == 'fulfilled') {
      this.categories = resArr[1].value.data.result as CategoryItem[]
      AppStorage.setOrCreate("categoryData", this.categories)
    }
    if (resArr[2].status == 'fulfilled') {
      this.saleGoods = (resArr[2].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[3].status == 'fulfilled') {
      this.hotGoods = (resArr[3].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[4].status == 'fulfilled') {
      this.oneGoods = (resArr[4].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[5].status == 'fulfilled') {
      this.newGoods = resArr[5].value.data.result as MkGoodsItem[]
    }
    if (resArr[6].status == 'fulfilled') {
      // this.recommendGoods = resArr[6].value.data.result as MkGoodsItem[]
      // 替换为数据源中的替换的方法
      this.recommendGoodsLazy.reloadData(resArr[6].value.data.result as object[])
    }
  }

  // 触底加载更多
  async getMoreData() {
    // 累加
    this.page++
    // 获取 对应的数据 赋值给数组
    const res = await getRecommendApi(this.page * 8)
    // 直接赋值
    // this.recommendGoods = res.data.result
    // 替换为懒加载的数据
    this.recommendGoodsLazy.reloadData(res.data.result)
  }

  // 刷新数据
  async refreshData() {
    // 有可能加载了更多数据
    this.page = 1
    // 重新获取所有的数据
    await this.getAllData()
  }

  @Builder
  DiscountBuilder(params: Params) {

    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('[basic].color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('[basic].color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: MkGoodsItem) => {
          ListItem() {
            DiscountGoodsComp({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
    .margin({

      top: AppStorage.get<number>('safeTop')
    })
  }

  // 下拉刷新 Builder
  @Builder
  RefreshBuilder() {
    Row() {
      MkLoading()
    }
    .width('100%')
    .padding(10)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Navigation(this.pathStack) {
      if (this.isLoading) {
        MkLoading();
      } else {
        Refresh({ refreshing: this.refresh, builder: this.RefreshBuilder() }) {
          Scroll() {
            Column() {
              // 轮播图 + 搜索
              Stack({ alignContent: Alignment.Top }) {
                Swiper() {
                  ForEach(this.banners, (item: Banner) => {
                    Image(item.imgUrl)
                  })
                }
                // 轮播图张数
                .displayCount(new BreakPointType({
                  sm: 1,
                  md: 2,
                  lg: 3
                }).getValue(this.currentBreakpoint))
                // 间隙
                .itemSpace(
                  new BreakPointType({
                    sm: 0,
                    md: 10,
                    lg: 20
                  }).getValue(this.currentBreakpoint)
                )
                // 底部的导航点
                .indicator(
                  this.currentBreakpoint !== BreakpointConstants.SM ?
                    false :
                    // 圆点模式
                  DotIndicator.dot()
                    .itemWidth(8)
                    .itemHeight(4)
                    .color('#33191919')
                    .selectedItemWidth(24)
                    .selectedItemHeight(4)
                    .selectedColor('#191919')
                )

                Row() {
                  Row({ space: 4 }) {
                    Image($r('[basic].media.ic_public_search'))
                      .width(16)
                      .height(16)
                      .fillColor($r('[basic].color.white'))
                    Text('搜索...')
                      .fontSize(14)
                      .fontColor($r('[basic].color.white'))
                  }
                  .backgroundColor('#33191919')
                  .width('100%')
                  .height(40)
                  .borderRadius(20)
                  .padding({ left: 12 })
                  .onClick(() => {
                    this.pathStack.pushPathByName('SearchView', null)
                  })
                }
                .padding({ left: 16, right: 16, top: this.safeTop })
              }
              .width('100%')

              // 分类
              Column({
                space: new BreakPointType({
                  sm: 14,
                  md: 36,
                  lg: 72
                }).getValue(this.currentBreakpoint)
              }) {
                // 分类
                List({ space: 16 }) {
                  ForEach(this.categories, (item: CategoryItem) => {
                    ListItem() {
                      Column() {
                        Image(item.picture)
                          .width(56)
                          .aspectRatio(1)
                        Text(item.name)
                          .fontSize(10)
                          .fontColor('#CC191919')
                      }
                      .width(60)
                      .height(80)
                      .borderRadius(30)

                      .clip(true)
                      .backgroundImage(item.picture)
                      .backgroundImageSize(ImageSize.Contain)
                      .backgroundImagePosition(Alignment.Center)
                      .backgroundBlurStyle(
                        BlurStyle.BACKGROUND_ULTRA_THICK,
                        { scale: 0.25 }
                      )
                    }
                  })
                }
                .width('100%')
                .height(92)
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
                .alignListItem(ListItemAlign.Center)

                // 特惠推荐
                Column({ space: 10 }) {
                  Image($r('app.media.home_cmd_title'))
                    .width(150)
                    .height(20)
                  Row() {
                    Image($r('app.media.home_cmd_inner'))
                      .width(86)
                      .height(116)
                    List({
                      space: new BreakPointType({
                        sm: 14,
                        md: 36,
                        lg: 72
                      }).getValue(this.currentBreakpoint)
                    }) {
                      ForEach(this.saleGoods, (item: MkGoodsItem) => {
                        ListItem() {
                          DiscountGoodsComp({ goods: item })
                        }
                      })
                    }
                    .layoutWeight(1)
                    .width('100%')
                    .height(116)
                    .backgroundColor($r('[basic].color.white'))
                    .borderRadius({
                      topRight: 8,
                      bottomRight: 8
                    })
                    .padding({ right: 10, left: 10 })
                    .scrollBar(BarState.Off)
                    .listDirection(Axis.Horizontal)
                  }
                }
                .width('100%')
                .height(166)
                .backgroundImage($r('app.media.home_cmd_sm'))
                .backgroundImageSize(ImageSize.Cover)
                .borderRadius(8)
                .padding(10)
                .alignItems(HorizontalAlign.Start)

                // 爆款推荐+一站买全
                Row({ space: 10 }) {
                  this.DiscountBuilder({
                    title: '爆款推荐',
                    subTitle: '最受欢迎',
                    bg: '#EDF1FB',
                    list: this.hotGoods
                  })
                  this.DiscountBuilder({
                    title: '一站买全',
                    subTitle: '精心优选',
                    bg: '#FCF6EA',
                    list: this.oneGoods
                  })
                }

                // 新鲜好物
                Column({ space: 10 }) {
                  Image($r('app.media.home_new'))
                    .width(146)
                    .height(19)
                  List({
                    space: new BreakPointType({
                      sm: 14,
                      md: 36,
                      lg: 72
                    }).getValue(this.currentBreakpoint)
                  }) {
                    ForEach(this.newGoods, (item: MkGoodsItem) => {
                      ListItem() {
                        DiscountGoodsComp({ type: DiscountType.NEW, goods: item })
                      }
                    })
                  }
                  .width('100%')
                  .height(116)
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                }
                .width('100%')
                .height(156)
                .padding(10)
                .backgroundColor('#F7EFF5')
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                // 推荐商品
                WaterFlow() {
                  // ForEach(this.recommendGoods, (item: MkGoodsItem) => {
                  LazyForEach(this.recommendGoodsLazy, (item: MkGoodsItem) => {
                    FlowItem() {
                      MkGoods({ goods: item })
                    }
                  })
                }
                .columnsTemplate(new BreakPointType({
                  sm: '1fr 1fr',
                  md: '1fr 1fr 1fr',
                  lg: '1fr 1fr 1fr 1fr'
                }).getValue(this.currentBreakpoint))
                .columnsGap(8)
                .rowsGap(10)

              }
              .padding({
                left: 8,
                right: 8,
                bottom: 10,
                top: 10
              })
            }
          }
          .scrollBar(BarState.Off)
          .onReachEnd(async () => {
            this.getMoreData()
          })
          // 显示的淡入效果
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
        }
        .onRefreshing(async () => {
          this.refresh = true;
          await this.refreshData()
          this.refresh = false
        })
      }
    }
  }
}