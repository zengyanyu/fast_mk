// 其他略
import { HmSku, HmSpec, MkGoodsItem } from '@mk/basic';

export interface GoodsProperty {
  name: string;
  value: string;
}

export interface GoodsDetail {
  pictures: string[];
  properties: GoodsProperty[];
}

export interface Goods extends MkGoodsItem {
  inventory: number
  mainPictures: string[]
  details: GoodsDetail
  specs: HmSpec[]
  skus: HmSku[]
}