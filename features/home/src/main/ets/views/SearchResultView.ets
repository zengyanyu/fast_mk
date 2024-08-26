import { MkGoodsItem, MKPullToRefresh } from '@mk/basic'
import { MkGoods } from '../components/MkGoods'
import { promptAction } from '@kit.ArkUI'
import { MKDataSource } from '../viewmodel/index'
import { searchGoodsApi } from '../api'

// 联合类型
export type SortField = 'publishTime' | 'orderNum' | 'price'

export type SortMethod = 'desc' | 'asc'

// 提交给服务器的参数
export interface SearchParams {
  keyword: string
  sortField: SortField
  sortMethod: SortMethod
  page: number
  pageSize: number
}

// 筛选条件
export interface SortCompAttr {
  field: SortField
  label: string
}


// 路由参数
interface RouterParam {
  keyword: string
}

@Builder
function SearchResultViewBuilder() {
  SearchResultView()
}

@Component
export struct SearchResultView {
  // 顶部安全区域
  @StorageProp('safeTop') safeTop: number = 0
  // mock 数据
  @State data: MkGoodsItem[] = new Array(8).fill({
    "id": "4033959",
    "name": "3秒快速拆琴轻松保养odin奥丁12半音阶口琴",
    "price": 329,
    "picture": "https://yanxuan-item.nosdn.127.net/937a8e46a9284e8f7e00e13911ecfbe7.png",
    "payCount": 0
  })
  @State dataLazy: MKDataSource = new MKDataSource()
  // 查询参数
  @State
  @Watch('paramsChange')
  params: SearchParams =
    {
      keyword: '',
      sortField: 'publishTime',
      sortMethod: 'desc',
      page: 1,
      pageSize: 10
    }
  // 总页数
  pages: number = 1
  @Consume
  pathStack: NavPathStack
  // 筛选条件
  sortList: SortCompAttr[] = [
    { label: '时间', field: 'publishTime' },
    { label: '销量', field: 'orderNum' },
    { label: '价格', field: 'price' }
  ]
  // 控制器
  scroller = new Scroller()

  // 查询数据的方法
  async queryData() {
    const res = await searchGoodsApi(this.params)
    // Logger.info(res.data.result.pageData)
    // this.data = res.data.result.pageData.items
    // 替换为 LazyForEach 的数据源
    this.dataLazy.reloadData(res.data.result.pageData.items)

    // 保存总页数
    this.pages = res.data.result.pageData.pages
  }

  aboutToAppear(): void {
    // 解析参数
    const keyword = this.pathStack.getParamByName('SearchResultView')[0] as string
    this.params.keyword = keyword
    //  查询数据
    this.queryData()
  }

  paramsChange() {
  }

  // 触底加载更多
  async loadMore() {
    // 比较是否到底
    if (this.params.page < this.pages) {
      this.params.page++
      const res = await searchGoodsApi(this.params)
      // ForEach 的数据源
      // this.data.push(...res.data.result.pageData.items as MkGoodsItem[])
      // LazyForEach的数据源
      res.data.result.pageData.items.forEach(item => {
        this.dataLazy.pushData(item)
      })

    } else {
      promptAction.showToast({
        message: '到底啦~'
      })
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 搜索区域
        Row() {
          Image($r('[basic].media.ic_public_left'))
            .width(24)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
            .margin(13)
            .onClick(() => {
              this.pathStack.pop()
            })
          Search({ placeholder: '商品关键字...', value: this.params.keyword })
            .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
            .placeholderColor($r('[basic].color.gray'))
            .placeholderFont({ size: 14 })
            .backgroundColor($r('[basic].color.white'))
            .textFont({ size: 14 })
            .layoutWeight(1)
            .padding(0)
            .margin(0)
            .height(36)
            .caretStyle({ color: $r('[basic].color.red') })
            .onSubmit((value) => {
              this.params.keyword = value
              this.queryData()
            })
        }
        .padding({ top: this.safeTop, right: 16 })
        .linearGradient({
          angle: 135,
          colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
        })

        // list
        Row() {
          ForEach(this.sortList, (item: SortCompAttr) => {
            // 筛选组件
            SortItemComp({
              label: item.label,
              field: item.field,
              sortField: this.params.sortField,
              sortMethod: this.params.sortMethod,
              onClickItem: (sortField: string, sortMethod: string) => {
                // Logger.info(sortField + '|' + sortMethod)
                // 更新筛选条件
                this.params.sortField = sortField as SortField
                this.params.sortMethod = sortMethod as SortMethod
                // 调用接口
                this.queryData()
              }
            })
          })
          Text('筛选')
            .fontSize(14)
            .fontColor($r('[basic].color.gray'))
        }
        .padding({ left: 16, right: 16 })
        .height(50)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .border({ width: { bottom: 0.5 }, color: $r('[basic].color.border') })

        MKPullToRefresh({
          // 必传项，列表组件所绑定的数据
          data: $dataLazy,
          // 必传项，需绑定传入主体布局内的列表或宫格组件
          scroller: this.scroller,
          // 必传项，自定义主体布局，内部有列表或宫格组件
          customList: () => {
            // 一个用@Builder修饰过的UI方法
            // this.getListView();
            this.waterFlowBuilder()
          },
          // 可选项，下拉刷新回调
          onRefresh: async () => {
            // 清空数据
            // 清空的方法没有单独准备，直接 reloadData
            this.dataLazy.reloadData([])
            // 还原页码
            this.params.page = 1
            // 获取数据
            await this.queryData()
            // 设置提示信息即可
            return '刷新成功~'
          },
          // 可选项，上拉加载更多回调
          onLoadMore: async () => {
            await this.loadMore()
            return ''
          },
          customLoad: null,
          customRefresh: null,
        })
          .layoutWeight(1)


      }
    }
    .hideTitleBar(true)
  }

  @Builder
  waterFlowBuilder() {
    WaterFlow({ scroller: this.scroller }) {
      // ForEach(this.data, (item: MkGoodsItem) => {
      LazyForEach(this.dataLazy, (item: MkGoodsItem) => {
        FlowItem() {
          MkGoods({ goods: item, smallImage: true })
        }
      })
    }
    .columnsTemplate("1fr 1fr")
    .columnsGap(0.5)
    .rowsGap(0.5)
    .layoutWeight(1)
  }
}

@Component
struct SortItemComp {
  // 筛选字段
  field: SortField = 'publishTime'
  // 显示的文本
  label: string = ''
  // 状态变量，接收父组件的状态属性
  // 父组件的筛选字段
  @Prop sortField: SortField = 'publishTime'
  // 父组件的排序方法
  @Prop sortMethod: SortMethod = 'desc'
  //  点击筛选条件，回传  sortField 和 sortMethod 给父组件（回调函数）
  onClickItem: (sortField: string, sortMethod: string) => void = (sortField: string, sortMethod: string) => {
  }

  build() {
    Row() {
      Text(this.label)
        .fontWeight(500)
        .fontSize(14)// 全局的排序字段和当前组件的字段名相同 高亮
        .fontColor(this.sortField === this.field ? $r('[basic].color.black') : $r('[basic].color.gray'))
      Column() {
        Image($r('[basic].media.ic_public_up'))
          .width(15)
          .height(6)
          .fillColor(this.sortField === this.field && this.sortMethod === 'asc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
        Image($r('[basic].media.ic_public_down'))
          .width(15)
          .height(6)// 全局的排序组件和当前的字段相同，并且根据 asc 及 desc 修改箭头的高亮
          .fillColor(this.sortField === this.field && this.sortMethod === 'desc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
      }
      .justifyContent(FlexAlign.Center)
    }
    .onClick(() => {
      // 重复点击 asc <-> 互换即可
      if (this.field === this.sortField) {
        this.onClickItem(this.field, this.sortMethod === 'asc' ? 'desc' : 'asc')
      } else {
        // 从其他筛选条件切过来
        // 传递筛选字段，及排序的方法
        this.onClickItem(this.field, 'desc')
      }
    })
  }
}