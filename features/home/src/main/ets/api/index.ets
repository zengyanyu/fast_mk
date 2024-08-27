import { Banner, CategoryItem, HotResult, MkGoodsItem, RequestAxios, SearchResult } from '@mk/basic'
import { Goods } from '../viewmodel'
// 数据类型已经提供好了
import { SearchParams } from '../views/SearchResultView'

export const getBannerApi = () => {
  return RequestAxios.get<Banner[]>('/home/banner')
}

export const getCategoryApi = () => {
  return RequestAxios.get<CategoryItem[]>('/home/category/head')
}

// 特惠推荐
export const getPreferenceApi = () => {
  return RequestAxios.get<HotResult>('/hot/preference')
}

// 爆款推荐
export const getHotApi = () => {
  return RequestAxios.get<HotResult>('/hot/inVogue')
}

// 一站买全
export const getOneApi = () => {
  return RequestAxios.get<HotResult>('/hot/oneStop')
}

// 获取新鲜好物数据
export const getNewApi = () => {
  return RequestAxios.get<MkGoodsItem[]>('/home/new')
}

export const getRecommendApi = (limit: number = 8) => {
  return RequestAxios.get<MkGoodsItem[]>('/home/recommend', {
    params: {
      limit
    }
  })
}

// 查询数据
export const searchGoodsApi = (data: SearchParams) => {
  return RequestAxios.post<SearchResult>('/search/all', data)
}

export const getGoodsApi = (id: string) => {
  return RequestAxios.get<Goods>('/goods', {
    params: {
      id
    }
  })
}

