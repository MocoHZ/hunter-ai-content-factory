"""
微博热搜内容工作流
用于自动化处理微博热搜采集、生成、发布
"""

from src.factory.weibo_content import WeiboContentFactory
from src.factory.publisher.weibo_publisher import WeiboPublisher


class WeiboWorkflow:
    """微博热搜内容工作流"""

    @staticmethod
    async def run():
        contents = await WeiboContentFactory.get_hot_contents()
        await WeiboPublisher.publish_hot()
        # 可扩展更多自动化处理逻辑
        return contents
