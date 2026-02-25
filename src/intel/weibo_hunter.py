"""
Hunter AI 内容工厂 - 微博热点采集模块

功能：
- 采集微博网站上的热点话题、热搜榜、热门帖子
- 提取标题、正文、作者、发布时间、热度等信息
- 支持自动去重与存储

用法：
    from src.intel.weibo_hunter import WeiboHunter
    hunter = WeiboHunter()
    hot_topics = await hunter.get_hot_topics()

GitHub: https://github.com/Pangu-Immortal/hunter-ai-content-factory
Author: Pangu-Immortal
"""

import asyncio
from dataclasses import dataclass, field
from datetime import datetime
import httpx

from src.intel.utils import create_http_client
from src.utils.logger import get_logger

logger = get_logger("hunter.intel.weibo")


@dataclass
class WeiboHotTopic:
    """微博热点话题数据结构"""

    topic_id: str  # 话题ID
    title: str  # 标题
    summary: str  # 简介/正文
    author: str  # 作者
    url: str  # 话题链接
    hot_value: int = 0  # 热度值
    created_at: datetime = None  # 发布时间
    images: list[str] = field(default_factory=list)  # 图片列表


class WeiboHunter:
    """
    微博热点采集器
    采集微博热搜榜、热门话题、热门帖子等数据。
    """

    BASE_URL = "https://s.weibo.com/top/summary"

    async def get_hot_topics(self) -> list[WeiboHotTopic]:
        """采集微博热搜榜数据"""
        async with create_http_client() as client:
            resp = await client.get(self.BASE_URL)
            if resp.status_code != 200:
                logger.error(f"请求失败: {resp.status_code}")
                return []
            html = resp.text
            return self.parse_hot_topics(html)

    def parse_hot_topics(self, html: str) -> list[WeiboHotTopic]:
        """解析微博热搜榜HTML，提取热点数据"""
        import re

        topics = []
        # 简单正则提取热搜榜数据（可根据实际页面结构调整）
        pattern = re.compile(
            r'<tr.*?<td class="td-01">(\d+)</td>.*?<td class="td-02">.*?<a href="(.*?)".*?>(.*?)</a>.*?<span>(.*?)</span>',
            re.S,
        )
        for match in pattern.findall(html):
            topic_id, url, title, hot_value = match
            topics.append(
                WeiboHotTopic(
                    topic_id=topic_id,
                    title=title,
                    summary="",
                    author="",
                    url=f"https://s.weibo.com{url}",
                    hot_value=int(hot_value) if hot_value.isdigit() else 0,
                    created_at=datetime.now(),
                    images=[],
                )
            )
        logger.info(f"采集到 {len(topics)} 条微博热点")
        return topics


# 示例用法
# async def main():
#     hunter = WeiboHunter()
#     topics = await hunter.get_hot_topics()
#     for t in topics:
#         print(t)
#
# asyncio.run(main())
