import { auth, CartGoods, RequestAxios } from '../../../../Index'

interface AddParams {
  skuId: string
  count: string
}

interface CountResult {
  count: number
}

interface UpdateParams {
  selected?: boolean
  count?: string
}

interface CheckAllParams {
  selected: boolean
}

interface DeleteParams {
  ids: string[]
}


export const CartKey: string = 'cartCount'

export class Cart {
  add(data: AddParams) {
    return RequestAxios.post<null>('/member/cart', data)
  }

  // 个数
  async count() {
    // 未登录 直接返回 0
    if (!auth.getUser()
      .token) {
      return 0
    }
    // 登录了 通过接口获取 保存到 AppStorage 中即可
    const res = await RequestAxios.get<CountResult>('/member/cart/count')
    AppStorage.setOrCreate(CartKey, res.data.result.count)
    return res.data.result.count

  }

  // 列表
  async list() {
    return RequestAxios.get<CartGoods[]>('/member/cart')
  }

  // 更新
  update(skuId: string, data: UpdateParams) {
    return RequestAxios.put<null>(`/member/cart/${skuId}`, data)
  }

  // 全选
  checkAll(data: CheckAllParams) {
    return RequestAxios.put<null>(`/member/cart/selected`, data)
  }

  // 删除
  async remove(data: DeleteParams) {
    // delete 的第二个参数是 config 和 get 类似
    return RequestAxios.delete<null>('/member/cart', {
      data: data // ArkTS可以简写
    })
  }
}

export const cart = new Cart()