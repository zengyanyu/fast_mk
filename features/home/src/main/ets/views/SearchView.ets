import { window } from '@kit.ArkUI'
import { AudioSearchComp } from '../components/AudioSearchComp'

// 定义一个 全局的 Builder 页面的组件丢到这个 builder 中，才可以跳转
@Builder
function SearchViewBuilder() {
  SearchView()
}

@Component
export struct SearchView {
  @StorageProp('safeTop') safeTop: number = 0
  @State keyword: string = ''
  @Consume // 传递给后代组件
  pathStack: NavPathStack

  aboutToAppear(): void {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#FFFFFF' })
      })
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#000000' })
      })
  }

  build() {
    // 希望路由跳转到这个页面，需要用 NavDestination 包裹
    NavDestination() {
      Column() {
        // search
        Row() {
          Image($r('[basic].media.ic_public_left'))
            .width(24)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
            .margin(13)
            .onClick(() => {
              // 返回
              this.pathStack.pop()
            })
          // 搜索组件
          Search({ placeholder: '商品关键字...', value: this.keyword })
            .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })// 图标
            .placeholderColor($r('[basic].color.gray'))// 提示信息文本
            .placeholderFont({ size: 14 })// 提示信息大小
            .searchButton('搜索', { fontSize: 14, fontColor: $r('[basic].color.red') })// 搜索按钮的外观
            .backgroundColor($r('[basic].color.white'))
            .textFont({ size: 14 })
            .layoutWeight(1)
            .padding(0)
            .margin(0)
            .height(36)
            .caretStyle({ color: $r('[basic].color.red') })
            .defaultFocus(true)// 获取焦点
            .onSubmit((value) => {
              // 点击搜索或者小键盘的搜索时触发
              // value 输入的内容
              // AlertDialog.show({
              //   message: value
              // })
              this.pathStack.pushPathByName('SearchResultView', value)
            })
        }
        .padding({ top: this.safeTop, right: 16 })
        .linearGradient({
          angle: 135,
          colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
        })

        // 语音识别的组件
        AudioSearchComp({
          // 实时更新
          onChange: (keyword: string) => {
            this.keyword = keyword
          },
          // 最终提交
          onComplete: (keyword: string) => {
            // Logger.info('onComplete' + keyword)
            // 携带 最终的文本，跳转到 搜索结果页
            // 输入完毕之后，希望让用户调整文本，自行跳转，注释下面这行即可
            this.pathStack.pushPathByName('SearchResultView', keyword)
          }
        })
      }
    }
    .hideTitleBar(true)
  }
}