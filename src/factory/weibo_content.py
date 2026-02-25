"""
微博热搜内容生成器
用于后续内容工厂自动化处理
"""

from src.intel.weibo_hunter import WeiboHunter
import asyncio


class WeiboContentFactory:
    """微博热搜内容生成器"""

    @staticmethod
    async def get_hot_titles():
        hunter = WeiboHunter()
        topics = await hunter.get_hot_topics()
        return [t.title for t in topics]

    @staticmethod
    async def get_hot_contents():
        hunter = WeiboHunter()
        topics = await hunter.get_hot_topics()
        return [f"标题: {t.title}\n热度: {t.hot_value}\n链接: {t.url}" for t in topics]
