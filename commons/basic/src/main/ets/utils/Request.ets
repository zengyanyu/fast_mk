import axios, { InternalAxiosRequestConfig, AxiosError, AxiosResponse, AxiosRequestConfig } from '@ohos/axios'

// 实例化 通用配置
const instance = axios.create({
  baseURL: 'https://meikou-api.itheima.net/',
  timeout: 5000
})

// 拦截器配置
// 请求拦截器
// token配置等
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
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
}, (error: AxiosError) => {
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

