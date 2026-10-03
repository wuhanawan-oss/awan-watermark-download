# 阿万去水印 v1.2 下载

Windows 64 位完整离线包。此仓库分发基于原阿万 v1.2 的本地修改版：批量排队、FGT FP16 混合精度、兼容 MP4 导出、可选预览。

**[打开下载页面](https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest)**

## Windows 终端下载

在 PowerShell 中执行下面两行。脚本会下载三个分卷，校验 SHA256，再合并为完整 ZIP。默认保存到桌面的 `Awan-Download-20261003` 文件夹，不会运行软件。

```powershell
Invoke-WebRequest -Uri "https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest/download/Download-Awan.ps1" -OutFile Download-Awan.ps1 -UseBasicParsing
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Awan.ps1
```

当前完整 ZIP 大小为 4,057,295,307 字节，解压内容约 6.78 GB。下载脚本保留分卷及合并后的 ZIP，需要约 8.2 GB 下载空间；连同解压文件建议预留 16 GB。下载前可查看仓库中的 [下载脚本](Download-Awan.ps1)。

完整 ZIP 的 SHA256：

```text
fca200939c44a5491b45ef0e49d359e193c1496451afd054a109f6b8de046f8a
```

## 启动

1. 将整个 ZIP 解压到独立文件夹，不能只取出 EXE，也不能直接在 ZIP 中运行。
2. 双击“阿万去水印.exe”，或运行 Launch.cmd。
3. 本机页面地址为 `http://127.0.0.1:8765/`。
4. 如果旧版后台仍在运行，先在旧版目录执行 Stop.cmd，再启动这个版本。仅关闭浏览器不会退出后台。

带有私有 Python 和模型，正常使用无需另装 Python 或重新下载模型。NVIDIA CUDA 加速需要可用的驱动；没有 CUDA 时使用 CPU / FP32。

## 功能

- 默认输出兼容 H.264 / yuv420p MP4，另有无损 RGB MP4 可选。
- CUDA 上 FGT 默认 FP16 混合精度，可选择 FP32；模型权重与部分计算仍为 FP32。
- 3 秒预览可选，可以直接提交完整视频。
- 多视频分别设置水印区域后排队，最多 64 个进行中或等待任务，逐个处理。
- 同尺寸视频可以主动复用设置；不同尺寸需分别设置。
- 一个任务失败后继续下一项，各项结果分别下载。
- 关闭页面不取消已提交任务；退出或重启软件后不自动恢复未完成任务。

## 验证范围与来源

完整 ZIP 已做 CRC 检查，三个分卷与合并结果已核验 SHA256。修改代码已做语法检查及模拟排队测试。

此次修改没有运行真实模型或视频；新 FP16 路径的实际速度、画质和不同机器兼容性仍需试用。模型推测被遮挡内容，不能保证完全还原。

此版本不是原作者正式新版。原作者信息、开源来源和第三方许可文件保留在完整包中。本包不包含原用户的输入视频、输出视频、历史任务、运行日志和修改备份。
