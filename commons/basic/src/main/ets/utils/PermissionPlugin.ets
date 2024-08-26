import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';

class PermissionPlugin {
  async checkAccessToken(permission: Permissions) {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      const accessTokenId = bundleInfo.appInfo.accessTokenId
      const grantStatus = await atManager.checkAccessToken(accessTokenId, permission);
      return grantStatus;
    } catch (e) {
      return abilityAccessCtrl.GrantStatus.PERMISSION_DENIED
    }
  }

  async checkPermissions(permissions: Permissions[]) {
    let flag = true
    for (let permission of permissions) {
      const grantStatus = await this.checkAccessToken(permission)
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        flag = false
      }
    }
    return flag
  }

  // 申请权限
  async requestPermissions(permissions: Permissions[]) {
    const atManager = abilityAccessCtrl.createAtManager();
    const res = await atManager.requestPermissionsFromUser(getContext(), permissions)
    const flag = res.authResults.every(grantStatus => grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    if (!flag) {
      return Promise.reject()
    } else {
      return Promise.resolve()
    }
  }
}

// 暴露实例对象
export const permissionPlugin = new PermissionPlugin()