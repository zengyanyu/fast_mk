// commons/basic/src/main/ets/constants/index.ets
import { emitter } from '@kit.BasicServicesKit';

export class BreakpointConstants {
  // 手表等超小屏
  static readonly XS: string = 'xs';
  // 手机竖屏
  static readonly SM: string = 'sm';
  // 手机横屏，折叠屏
  static readonly MD: string = 'md';
  // 平板，2in1 设备
  static readonly LG: string = 'lg';
  // AppStorage 中的 key
  static readonly BREAK_POINT_KEY: string = 'currentBreakpoint'
}

export class EmitterKey {
  // 切换 tab
  static CHANGE_TAB: emitter.InnerEvent = { eventId: 10001 }
  // 刷新购物车列表
  static REFRESH_LIST: emitter.InnerEvent = { eventId: 10002 }
  // 刷新地址
  static REFRESH_ADDRESS: emitter.InnerEvent = { eventId: 10003 }
}