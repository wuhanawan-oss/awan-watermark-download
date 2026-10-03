# 阿万去水印下载

当前本地修改版：**v1.2.1 — 排队任务可取消**。Windows 64 位，保留原来的批量排队、FP16 混合精度、兼容 MP4 导出和可选预览。

**[最新下载页面](https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest)**

## 已有软件：只下载升级包

[下载 v1.2.1 升级包（约 0.86 MB）](https://github.com/wuhanawan-oss/awan-watermark-download/releases/download/v1.2.1-queue-cancel-20261004/Awan-update-v1.2.1-win64.zip)

1. 等当前处理完成，在原软件目录运行 Stop.cmd 退出后台。
2. 将升级包解压到“阿万去水印.exe”所在目录，覆盖同名文件。
3. 再启动软件并刷新页面。仅刷新网页不能更新后台。

保留模型、视频、结果与历史记录，不必重下完整软件。

## 新安装：Windows 终端下载

在 PowerShell 执行以下两行：

```powershell
Invoke-WebRequest -Uri "https://github.com/wuhanawan-oss/awan-watermark-download/releases/latest/download/Download-Awan.ps1" -OutFile Download-Awan.ps1 -UseBasicParsing
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Download-Awan.ps1
```

脚本下载并校验原 v1.2 完整离线运行环境（约 4.06 GB），合并分卷，解压到桌面的 `Awan-Download-20261004/software-v1.2.1`，然后应用本次升级。请预留约 16 GB 空间。脚本不会启动软件或模型；完成后进入软件目录双击“阿万去水印.exe”。

旧版完整分卷保留在 [v1.2 下载版本](https://github.com/wuhanawan-oss/awan-watermark-download/releases/tag/v1.2-batch-fp16-20261003)，新脚本固定下载这些已验证的基础文件，再应用 v1.2.1 更新。

## 取消排队

- 等待中的任务点击“取消排队”，后台跳过它并继续下一条。
- 显示“已取消，未处理”，水印设置保留。
- 已取消任务不会被“将全部就绪视频加入队列”自动加回，需要时单独点“重新加入”。
- 取消仅适用于尚未开始的任务。任务已开始时会提示并刷新状态。
- 关闭页面不会取消任务；退出或重启软件后不自动恢复未完成任务。

## 原有功能

默认兼容 H.264 / yuv420p MP4；CUDA 上 FGT 默认 FP16 混合精度并可选择 FP32；3 秒预览可选；多视频分别设置水印后串行排队，最多 64 个进行中或等待任务。没有 CUDA 时使用 CPU / FP32。

## 验证与来源

取消行为使用实际代码和模拟任务验证，包括开始边界、失败回退、容量释放、后续继续及重新加入。基础安装包和升级包已校验；下载脚本使用小文件测试验证合并、解压、更新与路径限制。

此修改未运行真实模型或视频；FP16 实际性能、画质及不同机器兼容性仍需试用。本版不是原作者正式发布的新版，保留原作者、开源来源和第三方许可文件；发布包不包含原用户的视频、结果、历史任务、日志或备份。
