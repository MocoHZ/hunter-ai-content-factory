"""
微博热搜内容发布器
用于自动发布微博热搜相关内容
"""

from src.factory.weibo_content import WeiboContentFactory


class WeiboPublisher:
    """微博热搜内容发布器"""

    @staticmethod
    async def publish_hot():
        titles = await WeiboContentFactory.get_hot_titles()
        # 这里可以集成到内容工厂的发布流程
        for title in titles:
            print(f"发布微博热搜: {title}")
        return titles
