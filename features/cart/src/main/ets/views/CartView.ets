import {
  auth,
  MkGuess,
  MkNavbar,
  MkUser,
  MKDialogLoading,
  CartGoodsModel,
  CartGoods,
  MKEmpty,
  EmitterKey,
  cart
} from '@mk/basic'
import { emitter } from '@kit.BasicServicesKit'


@Builder
function CartViewBuilder() {
  CartView()
}

@Component
export struct CartView {
  // 用户信息
  @StorageProp(auth.KEY) user: MkUser = {} as MkUser
  // 商品信息
  @State cartList: CartGoodsModel[] = []
  @State
  showLeft: boolean = false
  // 页面栈
  @Consume
  pathStack: NavPathStack

  aboutToAppear(): void {
    // 解析路由参数
    this.showLeft = !!this.pathStack.getParamByName('CartView')[0]

    this.getData()

    // 注册 刷新的回调
    emitter.on(EmitterKey.REFRESH_LIST, () => {
      this.getData()
    })

  }

  // 获取数据
  async getData() {
    if (!auth.getUser()
      .token) {
      return
    }
    this.dialog.open()
    const res = await cart.list()
    // Logger.info(res.data.result)
    this.cartList = res.data.result.map(v => {
      return new CartGoodsModel(v)
    })
    this.dialog.close()
  }

  @Builder
  DeleteBuilder(onDelete: () => void) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('[basic].color.red'))
      .fontColor($r('[basic].color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {
        onDelete()
      })
  }

  dialog = new CustomDialogController({
    builder: MKDialogLoading(),
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: '#00000000'
  })

  onCheckOrder() {
    AlertDialog.show({
      message: '去结算'
    })
  }

  // 是否全选
  isCheckedAll() {
    // 每一项都是 true every 返回的就是 true
    // 反之就是 false
    return this.cartList.every(v => v.selected)
  }

  // 总价格
  // 筛选-》累加-》小数位-》转字符串
  totalPrice() {
    return this.cartList
      .filter(v => v.selected)// prev 初始值或者是上一次的累加值，
        // curv 数组的每一项
      .reduce((prev, curv) => prev + curv.count * curv.price, 0)
      .toFixed(2)
      .toString()
  }

  build() {
    NavDestination() {
      Column() {
        MkNavbar({
          title: '购物袋',
          showLeftIcon: this.showLeft,
          showRightIcon: true,
          leftClickHandler: () => {
            this.pathStack.pop()
          }
        })
          .border({
            width: { bottom: 0.5 },
            color: '#e4e4e4'
          })
        List() {
          if (this.user.token) {
            if (this.cartList.length) {
              ForEach(this.cartList, (item: CartGoodsModel, index: number) => {
                ListItem() {
                  CartItemComp({
                    cart: item,
                    onChangeSelected: selected => {
                      // 更新数据
                      item.selected = selected
                      // 更新页面
                      this.cartList.splice(index, 1, item)
                    },
                    onChangeCount: count => {
                      // 更新数据
                      item.count = count
                      // 更新页面
                      this.cartList.splice(index, 1, item)
                    }
                  })
                }
                .backgroundColor($r('[basic].color.under'))
                .padding({ left: 8, right: 8 })
                .transition({ type: TransitionType.Delete, opacity: 0 })
                .swipeAction({
                  end: this.DeleteBuilder(async () => {
                    // AlertDialog.show({
                    //   message: 'clickDel'
                    // })
                    this.dialog.open()
                    await cart.remove({ ids: [item.skuId] })
                    this.cartList.splice(index, 1)
                    this.dialog.close()
                  })
                })
              }, (cart: CartGoods) => cart.skuId)
            } else {
              ListItem() {
                MKEmpty({
                  tip: '空空如也',
                  buttonText: '去看看',
                  onClickButton: () => {
                    emitter.emit(EmitterKey.CHANGE_TAB)
                  }
                })
              }
            }
          } else {
            // 未登录
            ListItem() {
              // Text('未登录')
              MKEmpty({
                tip: '未登录',
                buttonText: '去登录',
                onClickButton: () => {
                  this.pathStack.pushPathByName('LoginView', null)
                }
              })
            }
          }
          ListItem() {
            MkGuess()
              .margin({ top: 8, bottom: 8 })
          }

        }
        .contentStartOffset(8)
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.cartList.length) {
          Row() {
            Checkbox()
              .select(this.isCheckedAll())
              .selectedColor($r('[basic].color.red'))
              .onClick(async () => {
                this.dialog.open()
                const selected = this.isCheckedAll()
                await cart.checkAll({
                  selected: !selected
                })
                // 本地数据要更新
                this.cartList.forEach(v => v.selected = !selected)
                // 创建一个新对象，复制给 原始对象
                this.cartList = [...this.cartList]
                this.dialog.close()
                // 能够正常调用到这里，更新本地的数据即可
              })
            Text('全选')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .margin({ right: 20 })
            Text('合计:')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .margin({ right: 2 })
            Text(this.totalPrice())
              .fontSize(16)
              .fontWeight(500)
              .fontColor($r('[basic].color.red'))
              .layoutWeight(1)
            Button('去结算')
              .fontSize(14)
              .height(36)
              .backgroundColor($r('[basic].color.red'))
              .onClick(() => {

              })
          }
          .height(50)
          .width('100%')
          .backgroundColor($r('[basic].color.white'))
          .border({
            width: { top: 0.5, bottom: 0.5 },
            color: '#e4e4e4'
          })
          .padding({ left: 16, right: 16 })
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('[basic].color.under'))
    }
    .hideTitleBar(true)
  }
}

@Component
struct CartItemComp {
  @Prop cart: CartGoodsModel
  onChangeSelected: (selected: boolean) => void = () => {

  }
  onChangeCount: (count: number) => void = () => {

  }
  dialog = new CustomDialogController({
    builder: MKDialogLoading({ message: '' }),
    customStyle: true,
    alignment: DialogAlignment.Center,
  })

  build() {
    Row({ space: 10 }) {

      Checkbox()
        .select(this.cart.selected)
        .selectedColor($r('[basic].color.red'))
        .size({ width: 14, height: 14 })// 点击 click 的时候会触发选中状态修改，直接该没有问题
          // onChange -》点击状态变更-》onChange（修改了状态）-》onChange（死循环）
        .onClick(async () => {
          this.dialog.open()
          // 更新服务端
          await cart.update(this.cart.skuId, { selected: !this.cart.selected })
          // 更新本地
          this.cart.selected = !this.cart.selected
          // 通知父组件 刷新页面
          this.onChangeSelected(this.cart.selected)
          this.dialog.close()
        })
      Image(this.cart.picture)
        .width(80)
        .height(80)
      Column({ space: 8 }) {
        Text(this.cart.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize(14)
          .fontColor($r('[basic].color.black'))
          .width('100%')
        Row() {
          Text(this.cart.attrsText)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontColor($r('[basic].color.text'))
            .layoutWeight(1)
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .fillColor($r('[basic].color.gray'))
            .width(16)
            .height(16)
        }
        .padding({ left: 6, right: 4 })
        .width(100)
        .height(24)
        .backgroundColor($r('[basic].color.under'))
        .borderRadius(2)

        Row() {
          Text(`¥${this.cart.price}`)
            .fontSize(14)
            .fontWeight(500)
          Counter() {
            Text(this.cart.count.toString())
          }
          .onInc(async () => {
            this.dialog.open()
            await cart.update(this.cart.skuId, { count: this.cart.count + 1 + '' })
            this.cart.count++
            this.onChangeCount(this.cart.count)
            this.dialog.close()
          })
          .onDec(async () => {
            this.dialog.open()
            await cart.update(this.cart.skuId, { count: this.cart.count - 1 + '' })
            this.cart.count--
            this.onChangeCount(this.cart.count)
            this.dialog.close()
          })
          .enableDec(this.cart.count > 1)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(100)
    .padding(10)
    .border({ width: { bottom: 0.5 }, color: '#e4e4e4' })
    .backgroundColor($r('[basic].color.white'))
  }
}

