import { AddressItem, MkUser, RequestAxios } from '@mk/basic'

// 登录模型
export interface LoginData {
  account: string
  password: string
}

// 用户登录
export const loginAPI = (data: LoginData) => {
  return RequestAxios.post<MkUser>('/login', data)
}

// 获取地址
export const getAddressApi = () => {
  return RequestAxios.get<AddressItem[]>('/member/address')
}

export interface RequestType {
  address: string;
  contact: string;
  isDefault: 0 | 1; // 0 默认 1 非默认
  receiver: string;
}

// 新增地址
export const createAddressAPI = (data: RequestType) => {
  return RequestAxios.post<null>('/member/address', data)
}

// 更新
interface UpdateParams {
  isDefault: 0 | 1
}

export const updateAddressAPI = (id: string, data: RequestType) => {

  return RequestAxios.put<null>(`/member/address/${id}`, data)
}

export const updateAddressDefaultAPI = (id: string) => {
  const data: UpdateParams = {
    isDefault: 0
  }
  return RequestAxios.put<null>(`/member/address/${id}`, data)
}

// 删除地址
export const delAddressAPI = (id: string) => {
  return RequestAxios.delete<null>(`/member/address/${id}`)
}