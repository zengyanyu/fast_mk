import { AddressItem, EmitterKey, Logger, MkNavbar } from '@mk/basic';
import { createAddressAPI, RequestType, updateAddressAPI } from '../api';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';


// 拓展list自定义样式
@Extend(Row)
function listItemStyle() {
  .padding({ top: 4, bottom: 4 })
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('[basic].color.white'))
}

@Builder
function AddressCreateViewBuilder() {
  AddressCreateView()
}

@Component
export struct AddressCreateView {
  aboutToAppear(): void {
    // 将地址管理界面的参数,带过来
    const data = this.pathStack.getParamByName('AddressCreateView')[0] as object
    if (data) { // 判断有值在进行类型转换和赋值
      this.addressData = data as RequestType

      this.addressId = (data as AddressItem).id
    }
  }

  // 保存 id 区分编辑和新增
  addressId: string = ''
  @StorageProp('safeBottom')
  safeBottom: number = 0
  @State
  addressData: RequestType = {
    address: '', // 地址
    contact: '', // 联系电话
    isDefault: 0, // 是否默认地址, 0 默认
    receiver: ''// 地址收件人
  }
  @Consume
  pathStack: NavPathStack

  async onSubmit() {
    Logger.info(this.addressData)
    let message = ''
    if (this.addressId !== '') {
      const res = await updateAddressAPI(this.addressId, this.addressData)
      message = '修改成功'
    } else {
      const res = await createAddressAPI(this.addressData)
      message = '新增成功'
    }

    promptAction.showToast({
      message
    })
    emitter.emit(EmitterKey.REFRESH_ADDRESS)
    this.pathStack.pop()
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部区域
        MkNavbar({
          title: this.addressId ? '修改地址' : '新增地址',
        })

        // 地址信息表单
        Row() {
          List() {
            ListItem() {
              Row() {
                Text('收货人')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({
                  placeholder: '请填写收货人名称',
                  text: this.addressData.receiver
                })
                  .onChange((value) => {
                    this.addressData.receiver = value
                  })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
              }
              .listItemStyle()
            }

            ListItem() {
              Row() {
                Text('手机号码')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({
                  placeholder: '请填写收货人电话',
                  text: this.addressData.contact
                })
                  .onChange((value) => {
                    this.addressData.contact = value
                  })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
              }
              .listItemStyle()
            }


            ListItem() {
              Row() {
                Text('详细地址')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({
                  placeholder: '请填写详细地址',
                  text: this.addressData.address
                })
                  .onChange((value) => {
                    this.addressData.address = value
                  })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
              }
              .listItemStyle()
            }

            ListItem() {
              Row() {
                Text('设为默认地址')
                  .fontSize(14)
                  .fontColor(($r('[basic].color.black')))
                Toggle({
                  isOn: this.addressData.isDefault === 0
                , type: ToggleType.Checkbox
                })
                  .selectedColor(($r('[basic].color.red')))
              }
              .listItemStyle()
            }
          }
          .divider({
            strokeWidth: 1,
            color: '#eee'
          })
          .backgroundColor($r('[basic].color.white'))
          .padding({ left: 8, right: 8 })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        // 底部保存按钮
        Row() {
          Button('保存')
            .backgroundColor(($r('[basic].color.black')))
            .fontSize(14)
            .width('100%')
            .onClick(() => {
              this.onSubmit()
            })
        }
        .height(46)
        .padding({ left: 16, right: 16 })
      }
      .height('100%')
      .backgroundColor('#F5F4F9')
      .padding({ bottom: this.safeBottom })
    }
    .hideTitleBar(true)
  }
}
