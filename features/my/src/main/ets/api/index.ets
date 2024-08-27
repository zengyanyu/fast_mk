import { MkUser, RequestAxios } from '@mk/basic'

// 登录模型
export interface LoginData {
  account: string
  password: string
}

// 用户登录
export const loginAPI = (data: LoginData) => {
  return RequestAxios.post<MkUser>('/login', data)
}