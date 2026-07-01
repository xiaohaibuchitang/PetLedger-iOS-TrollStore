# 小离记账 iOS / TrollStore 打包工程

这个目录是把当前网页原型封装成 iOS App 的 Xcode 工程。App 启动后会用 `WKWebView` 加载内置的本地页面，不依赖外网。

## 为什么这里没有直接生成 IPA

当前工作环境是 Windows，没有 Xcode 和 iOS SDK。TrollStore 能安装的 `.ipa` 必须包含 iOS arm64 可执行文件，不能只把 HTML/CSS/JS 压成 IPA。所以这里交付的是可在 macOS 上直接打包的工程和脚本。

## 打包方式

### 方式 A：GitHub Actions 云端打包，没有 Mac 也可以

1. 新建一个 GitHub 仓库。
2. 把这个文件夹里的所有内容上传到仓库根目录。
3. 打开仓库的 `Actions` 页面。
4. 选择 `Build TrollStore IPA`。
5. 点击 `Run workflow`。
6. 构建完成后，在运行记录底部下载 `PetLedger-TrollStore-IPA`。

下载后会得到：

```text
PetLedger-TrollStore.ipa
```

把这个 IPA 传到手机后，用 TrollStore 打开安装。

### 方式 B：有 Mac 时本地打包

```sh
cd PetLedger-iOS-TrollStore
chmod +x build_trollstore_ipa.sh
./build_trollstore_ipa.sh
```

完成后会生成：

```text
PetLedger-TrollStore.ipa
```

把这个 IPA 传到手机后，用 TrollStore 打开安装。

## 可选：修改 Bundle ID

```sh
BUNDLE_ID=com.yourname.petledger ./build_trollstore_ipa.sh
```

## 目录说明

- `PetLedger.xcodeproj`：Xcode 工程。
- `PetLedger/ContentView.swift`：SwiftUI + WKWebView 壳。
- `PetLedger/web/`：内置的记账宠物原型页面。
- `build_trollstore_ipa.sh`：macOS 打包脚本。

## 注意

- 建议用 Xcode 15 或更新版本。
- 如果 TrollStore 拒绝安装，Mac 上安装 `ldid` 后重新运行脚本。
- 这个版本仍然是原型 App，数据保存在页面运行态里，还没有接入真正的本地数据库。
