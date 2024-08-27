export interface MkUser {
  token: string
  nickname: string
  avatar: string
  account: string
}

class Auth {
  KEY: string = 'user'

  // 增加 常驻数据的逻辑
  initUser() {
    PersistentStorage.persistProp<MkUser>(this.KEY, {} as MkUser)
  }

  getUser() {
    return AppStorage.get<MkUser>(this.KEY) || {} as MkUser
  }

  saveUser(user: MkUser) {
    AppStorage.setOrCreate<MkUser>(this.KEY, user)
  }

  removeUser() {
    AppStorage.setOrCreate<MkUser>(this.KEY, {} as MkUser)
  }
}

// 导出实例化对象
export const auth = new Auth()