// 默认值为 6
import { RequestAxios } from '../utils/Request'
import { GoodsItems } from '../viewmodel'

export const getGuessLikeApi = (limit: number = 6) => {
  return RequestAxios.get<GoodsItems>('/home/goods/guessLike', {
    params: {
      limit
    }
  })
}