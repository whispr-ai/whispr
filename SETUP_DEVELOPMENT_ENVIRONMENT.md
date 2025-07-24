# 开发环境设置指南

## API 密钥配置

为了保护敏感信息（如 API 密钥），项目使用模板文件的方式来管理配置。

### 初次设置步骤：

1. **复制模板文件**：
   ```bash
   cp whispr.xcodeproj/xcshareddata/xcschemes/whispr.xcscheme.template whispr.xcodeproj/xcshareddata/xcschemes/whispr.xcscheme
   ```

2. **配置 API 密钥**：
   打开复制的 `whispr.xcscheme` 文件，将 `YOUR_DEEPGRAM_API_KEY_HERE` 替换为你的实际 Deepgram API 密钥。

3. **验证配置**：
   确保 `.gitignore` 文件中包含了 `*.xcscheme` 规则，这样你的个人配置不会被提交到代码库。

### 获取 API 密钥：

- **Deepgram API**: 访问 [Deepgram Console](https://console.deepgram.com/) 注册并获取 API 密钥

### 注意事项：

- ⚠️ **绝对不要**将包含真实 API 密钥的 `whispr.xcscheme` 文件提交到 git
- ✅ 只提交 `whispr.xcscheme.template` 模板文件
- 🔄 如果模板文件有更新，请重新复制并重新配置你的 API 密钥

### 项目协作：

当新开发者加入项目时，只需要：
1. 克隆代码库
2. 按照上述步骤复制模板并配置 API 密钥
3. 开始开发 