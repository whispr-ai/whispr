# Deepgram API Key 配置指南

## 🔐 安全配置 API Key

现在 Deepgram API Key 已经从代码中移除，支持多种安全的配置方式：

## 📋 配置方式（按优先级排序）

### 1. Info.plist 配置（推荐用于开发）
在 Info.plist 中添加：
```xml
<key>DeepgramAPIKey</key>
<string>你的API密钥</string>
```

### 2. 环境变量（推荐用于生产）
设置环境变量：
```bash
export DEEPGRAM_API_KEY="xxx"
```

在 Xcode 中设置环境变量：
1. 选择 Scheme → Edit Scheme
2. 选择 "Run" → "Arguments"
3. 在 "Environment Variables" 中添加：
   - Name: `DEEPGRAM_API_KEY`
   - Value: `xxx`

### 3. 用户设置（运行时配置）
在代码中动态设置：
```swift
Configuration.setDeepgramAPIKey("你的API密钥")
```

### 4. 开发环境默认值
在 DEBUG 模式下会使用硬编码的密钥作为后备方案

## 🚀 如何使用

### 方法一：Xcode 环境变量设置
1. 在 Xcode 中，点击项目名称选择 "Edit Scheme"
2. 选择 "Run" → "Arguments" 选项卡
3. 在 "Environment Variables" 部分点击 "+"
4. 添加：
   - Name: `DEEPGRAM_API_KEY`
   - Value: `xxx`
5. 点击 "Close"

### 方法二：Info.plist 配置
1. 打开 `Info.plist` 文件
2. 添加新的键值对：
   - Key: `DeepgramAPIKey`
   - Type: String
   - Value: `xxx`

## ⚠️ 安全注意事项

1. **永远不要提交 API Key 到版本控制**
2. **生产环境使用环境变量**
3. **开发环境可以使用 Info.plist**
4. **定期轮换 API Key**

## 🔍 验证配置

应用启动时会在控制台打印 API Key 来源：
- `🔑 Deepgram API Key 来源: 环境变量`
- `🔑 Deepgram API Key 来源: Info.plist`
- `🔑 Deepgram API Key 来源: 用户设置`
- `🔑 Deepgram API Key 来源: 硬编码（开发环境）`

## 📝 .gitignore 建议

如果使用 Info.plist 配置，建议创建两个文件：
- `Info.plist` - 提交到版本控制，使用占位符
- `Info-Local.plist` - 本地配置，添加到 .gitignore

```gitignore
# API Keys
Info-Local.plist
*.plist.local
```
