# Hunter AI 内容工厂 - 产品说明书

## 产品概述

Hunter AI 内容工厂是一套 **AI 驱动的自媒体内容生产系统**，核心目标是：

**自动采集全网信息 → AI 分析加工 → 生成公众号文章 → 推送到微信**

## 核心模块

### 1. 情报采集层 (Intel)

| 模块 | 功能 | 数据源 |
|------|------|--------|
| GitHub Hunter | 搜索高星 AI 开源项目 | GitHub API |
| Pain Radar | 扫描用户抱怨和痛点 | Twitter |
| Auto Publisher | 综合采集+文章生成 | HN + Twitter |

### 2. 内容生产层 (Factory)

采用 **6-Skill 流水线架构**：

```
Topic → Research → Structure → Write → Package → Publish
选题     研究        结构化      写作      封装      发布
```

### 3. 内容精炼层 (Refiner)

- 深度洗稿（意译重构）
- 去 AI 化表达
- 统一排版
- 封面 Prompt 生成

## 技术栈

| 组件 | 选型 |
|------|------|
| Python | 3.12+ |
| 包管理 | UV |
| AI 模型 | Gemini 2.0 Flash |
| 向量数据库 | ChromaDB |
| 推送服务 | PushPlus |

## 使用场景

1. **公众号运营**：自动生成技术文章
2. **热点追踪**：实时监控 AI 领域动态
3. **竞品分析**：收集用户痛点反馈
4. **内容洗稿**：优化已有文章风格

## 交付物

- Word 报告（.docx）
- Markdown 文章（.md）
- 封面图 Prompt
- 微信推送通知
