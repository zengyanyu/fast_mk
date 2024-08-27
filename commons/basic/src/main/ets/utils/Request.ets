import axios, { InternalAxiosRequestConfig, AxiosError, AxiosResponse, AxiosRequestConfig } from '@ohos/axios'
import { auth } from './Auth'
import { promptAction } from '@kit.ArkUI'
import { MKNavPathStack } from './NavPathStack'

// 增加类型
export interface APIErrorType {
  message: string
  msg: string
  code: string
}

// 实例化 通用配置
const instance = axios.create({
  baseURL: 'https://meikou-api.itheima.net/',
  timeout: 5000
})

// 拦截器配置
// 请求拦截器
// token配置等
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 判断是否有用户信息
  const user = auth.getUser();
  if (user.token) {
    // 设置token信息
    config.headers['Authorization'] = `Bearer ${user.token}`
  }
  return config
}, (error: AxiosError) => {
  return Promise.reject(error)
})

// 抽取公共部分
export interface HttpResponse<T> {
  code: string
  msg: string
  result: T
}

// 简化后续编码
export type ResponseType<T> = AxiosResponse<HttpResponse<T>>

// 添加响应拦截器
// 错误统一处理等
instance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (error: AxiosError<APIErrorType>) => {
  if (error.response?.status === 400) {
    promptAction.showToast({
      message: error.response?.data.message
    })
  }
  if (error.response?.status === 401) {
    // 移除用户信息,去登录
    promptAction.showToast({
      message: '登录过期'
    })
    auth.removeUser()
    // 跳转到登录页面
    MKNavPathStack.popToName('LoginView')
  }
  if (error.response?.status === 500) {
    promptAction.showToast({
      message: '请求接口异常--状态码为:500'
    })
  }
  return Promise.reject(error)
})

export class RequestAxios {
  // get -> params -> { params: {} }
  // static get<T>(url: string, params?: object): Promise<ResponseType<T>> {
  //   return instance.get<null, ResponseType<T>>(url, { params })
  // }
  static get<T>(url: string, config?: AxiosRequestConfig): Promise<ResponseType<T>> {
    return instance.get<null, ResponseType<T>>(url, config)
  }

  static post<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.post<null, ResponseType<T>>(url, data)
  }

  static delete<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.delete<null, ResponseType<T>>(url, data)
  }

  static put<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.put<null, ResponseType<T>>(url, data)
  }
}

