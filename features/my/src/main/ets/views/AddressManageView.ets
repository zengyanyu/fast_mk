import { AddressItem, EmitterKey, MkNavbar } from '@mk/basic'
import { delAddressAPI, getAddressApi, updateAddressDefaultAPI } from '../api'
import { emitter } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

@Builder
function AddressManageViewBuilder() {
  AddressManageView()
}

@Component
export struct AddressManageView {
  // 获取数据
  @State
  addressList: AddressItem[] = []
  @StorageProp('safeBottom')
  safeBottom: number = 0
  @Consume
  pathStack: NavPathStack
  //
  getAddressList = async () => {
    const res = await getAddressApi()
    this.addressList = res.data.result
  }

  aboutToAppear(): void {
    this.getAddressList()

    emitter.on(EmitterKey.REFRESH_ADDRESS, () => {
      // 获取地址列表
      this.getAddressList()
    })
  }

  @Builder
  ActionBuilder(id: string) {
    Row() {
      Row() {
        Text('设为默认')
          .fontColor($r('[basic].color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
      }
      .layoutWeight(1)
      .height('100%')
      .onClick(async () => {
        await updateAddressDefaultAPI(id)
        this.getAddressList()
      })
      .backgroundColor($r('[basic].color.black'))

      Row() {
        Text('删除')
          .fontColor($r('[basic].color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
          .onClick(async () => {
            await delAddressAPI(id)
            promptAction.showToast({
              message: '删除成功'
            })
            this.getAddressList()
          })
      }
      .backgroundColor($r('[basic].color.red'))
      .layoutWeight(1)
      .height('100%')
    }
    .width(88)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部区域
        MkNavbar({
          title: '收货地址管理',
        })

        // 地址列表
        Row() {
          List() {
            ForEach(this.addressList, (item: AddressItem) => {
              ListItem() {
                Row() {
                  Column() {
                    Row() {
                      // 是否默认
                      if (item.isDefault == 0) {
                        Row() {
                          Text('默认')
                            .fontSize(13)
                            .fontColor($r('[basic].color.white'))
                        }
                        .borderRadius(2)
                        .padding({
                          left: 8,
                          right: 8,
                          top: 2,
                          bottom: 2
                        })
                        .linearGradient({
                          angle: '93',
                          colors: [
                            [
                              '#FD3F8F',
                              0
                            ],
                            [
                              '#FF773C',
                              1
                            ]
                          ]
                        })
                        .margin({
                          right: 4
                        })
                      }

                      Text(item.address)
                        .fontColor('#434343')
                        .fontSize(14)
                    }

                    Text(`${item.receiver} ${item.contact}`)
                      .margin({ top: 8 })
                      .fontSize(12)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Row() {
                    Image($r("app.media.ic_public_edit"))
                      .width(16)
                      .onClick(() => {
                        this.pathStack.pushPathByName('AddressCreateView', item)
                      })
                  }
                }
                .padding(16)
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .backgroundColor($r('[basic].color.white'))
              }
              .margin({ bottom: 10 })
              .swipeAction({
                // 右滑动
                end: () => {
                  this.ActionBuilder(item.id)
                }
              })
            }
            )
          }
          .width('100%')
          .height('100%')
        }
        .margin({ top: 8 })
        .padding({ left: 8, right: 8 })
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        // 底部新增地址
        Row() {
          Button('新增地址')
            .backgroundColor($r('[basic].color.black'))
            .fontSize(14)
            .width('100%')
            .onClick(() => {
              this.pathStack.pushPathByName('AddressCreateView', null)
            })
        }
        .height(46)
        .padding({ left: 16, right: 16, })
      }
      .height('100%')
      .backgroundColor('#F5F4F9')
      .padding({ bottom: this.safeBottom })
    }
    .hideTitleBar(true)
  }
}