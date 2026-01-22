# Hunter AI 内容工厂 - 工作流指南

## 工作流概述

本系统采用 **6-Skill 流水线架构**，每个 Skill 是一个独立的 AI 能力单元。

## 数据流图

```
┌─────────┐
│  Topic  │  选题：确定主题、角度、目标读者
└────┬────┘
     │ selected_topic, keywords
     │ target_audience, angle, potential_titles
     ▼
┌──────────┐
│ Research │  研究：收集信息、提取洞察
└────┬─────┘
     │ key_insights, notes, facts, references
     ▼
┌───────────┐  ← target_audience, angle (from Topic)
│ Structure │  结构化：设计大纲、开篇、结尾
└────┬──────┘
     │ hook, outline, closing
     ▼
┌─────────┐  ← target_audience, angle (from Topic)
│  Write  │  写作：撰写完整初稿
└────┬────┘  ← research_data (from Research)
     │ draft, actual_word_count
     ▼
┌─────────┐  ← potential_titles, target_audience (from Topic)
│ Package │  封装：优化标题、生成封面
└────┬────┘
     │ title, summary, draft_with_images
     ▼
┌─────────┐  ← pushplus_token (from config)
│ Publish │  发布：推送到微信
└────┬────┘
     │ push_status, push_time, message_id
     ▼
  [推送完成]
```

## Skill 详解

### 1. Topic（选题）

**输入**：
- `niche`: 细分领域
- `trends`: 当前趋势

**输出**：
- `selected_topic`: 选定主题
- `angle`: 切入角度
- `target_audience`: 目标读者
- `potential_titles`: 备选标题
- `keywords`: 关键词

### 2. Research（研究）

**输入**：
- `topic`: 选定主题
- `keywords`: 关键词

**输出**：
- `key_insights`: 核心洞察
- `notes`: 详细笔记
- `facts`: 关键事实
- `references`: 来源列表

### 3. Structure（结构化）

**输入**：
- `research_data`: 研究数据
- `target_audience`: 目标读者
- `angle`: 切入角度
- `tone`: 语气风格

**输出**：
- `hook`: 开篇钩子
- `outline`: 章节大纲
- `closing`: 结尾设计

### 4. Write（写作）

**输入**：
- `outline`: 大纲
- `hook`: 开篇钩子
- `closing`: 结尾设计
- `research_data`: 研究数据
- `target_audience`: 目标读者
- `length_constraints`: 长度限制
- `banned_words`: 违禁词

**输出**：
- `draft`: 完整初稿
- `actual_word_count`: 实际字数
- `readability_check`: 可读性评分

### 5. Package（封装）

**输入**：
- `draft`: 初稿
- `potential_titles`: 备选标题
- `target_audience`: 目标读者
- `tone`: 语气风格

**输出**：
- `title`: 最终标题（≤22字）
- `summary`: 摘要（≤120字）
- `cover_image_prompt`: 封面图 Prompt（含 2.35:1 比例）
- `draft_with_images`: 含图片的文章
- `seo_keywords`: SEO 关键词

### 6. Publish（发布）

**输入**：
- `title`: 标题
- `summary`: 摘要
- `draft_with_images`: 文章内容
- `pushplus_token`: 推送 Token

**输出**：
- `push_status`: 推送状态
- `push_time`: 推送时间
- `message_id`: 消息 ID

## 数据传递原则

1. **完整传递**: Topic 的输出贯穿整个工作流
2. **层级聚合**: Research 的输出在多个阶段被使用
3. **配置注入**: 全局配置注入到相关 Skill
4. **质量自检**: 每个 Skill 都有质量检查机制
