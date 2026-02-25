"""
Hunter AI 内容工厂 - 微博浏览器采集模块

功能：
- 基于 Playwright 浏览器自动化采集微博内容
- 绕过反爬验证，适合反爬较强场景
- 支持 Cookie 注入登录

使用方法：
    from src.intel.weibo_browser import WeiboBrowser

    browser = WeiboBrowser()
    posts = await browser.search("AI工具")

GitHub: https://github.com/Pangu-Immortal/hunter-ai-content-factory
Author: Pangu-Immortal
"""

import asyncio
from dataclasses import dataclass, field
from datetime import datetime
from src.utils.logger import get_logger

logger = get_logger("hunter.intel.weibo_browser")


@dataclass
class WeiboPost:
    """微博帖子数据"""

    post_id: str
    content: str
    author: str
    author_id: str = ""
    likes: int = 0
    reposts: int = 0
    comments: int = 0
    images: list[str] = field(default_factory=list)
    url: str = ""
    created_at: datetime | None = None

    def to_dict(self) -> dict:
        return {
            "post_id": self.post_id,
            "content": self.content,
            "author": self.author,
            "author_id": self.author_id,
            "likes": self.likes,
            "reposts": self.reposts,
            "comments": self.comments,
            "images": self.images,
            "url": self.url,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }


class WeiboBrowser:
    """
    微博浏览器采集器 - 基于 Playwright

    核心功能：
    1. 浏览器模拟 - 绕过反爬验证
    2. Cookie 注入 - 实现登录态
    3. 页面解析 - 提取微博内容
    """

    BASE_URL = "https://weibo.com"

    def __init__(self):
        self.cookies = self._load_cookies()
        self.browser = None
        self.context = None
        self.page = None

    def _load_cookies(self) -> list[dict]:
        """
        加载 Cookie 并转换为 Playwright 格式
        """
        # 示例：从 config.yaml 或 settings 读取微博 cookies
        # 这里返回空列表，实际可按需实现
        return []

    async def _init_browser(self):
        """
        初始化浏览器，注入 Cookie
        """
        from playwright.async_api import async_playwright
        logger.info("正在启动微博浏览器...")
        self._playwright = await async_playwright().start()
        self.browser = await self._playwright.chromium.launch(
            headless=True,
            args=[
                "--disable-blink-features=AutomationControlled",
                "--no-sandbox",
                "--disable-setuid-sandbox",
            ],
        )
        self.context = await self.browser.new_context(
            viewport={"width": 1920, "height": 1080},
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            locale="zh-CN",
            timezone_id="Asia/Shanghai",
        )
        if self.cookies:
            await self.context.add_cookies(self.cookies)
            logger.info(f"已注入 {len(self.cookies)} 个 Cookie")
        self.page = await self.context.new_page()
        await self.page.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
            window.chrome = { runtime: {} };
        """)
        logger.info("微博浏览器启动完成")

    async def close(self):
        """
        关闭浏览器
        """
        if self.browser:
            await self.browser.close()
            self.browser = None
        if hasattr(self, "_playwright") and self._playwright:
            await self._playwright.stop()
            self._playwright = None
        logger.info("微博浏览器已关闭")

    async def search(self, keyword: str, max_posts: int = 20) -> list[WeiboPost]:
        """
        搜索微博内容并采集帖子
        """
        if not self.page:
            await self._init_browser()
        logger.info(f"搜索关键词: {keyword}")
        try:
            # 访问微博搜索页
            search_url = f"https://s.weibo.com/weibo?q={keyword}&Refer=index"
            await self.page.goto(search_url, wait_until="networkidle", timeout=30000)
            await asyncio.sleep(2)
            # 检查是否需要登录
            page_content = await self.page.content()
            if "登录" in page_content and "注册" in page_content and len(page_content) < 5000:
                logger.warning("检测到登录页面，Cookie 可能已过期")
                return []
            # 滚动加载更多内容
            for _ in range(3):
                await self.page.evaluate("window.scrollBy(0, 1000)")
                await asyncio.sleep(1)
            # 解析微博帖子
            posts = await self._parse_search_results(max_posts)
            logger.info(f"搜索 '{keyword}' 找到 {len(posts)} 条微博")
            return posts
        except Exception as e:
            logger.error(f"搜索失败: {e}")
            return []

    async def _parse_search_results(self, count: int) -> list[WeiboPost]:
        """
        解析搜索结果页面，提取微博帖子
        """
        posts = []
        try:
            # 等待微博卡片加载
            await self.page.wait_for_selector('div.card, div[action-type="feed_list_item"]', timeout=10000)
            post_elements = await self.page.query_selector_all('div.card, div[action-type="feed_list_item"]')
            for element in post_elements[:count]:
                try:
                    post = await self._parse_post_card(element)
                    if post:
                        posts.append(post)
                except Exception as e:
                    logger.debug(f"解析微博卡片失败: {e}")
                    continue
        except Exception as e:
            logger.error(f"解析搜索结果失败: {e}")
        return posts

    async def _parse_post_card(self, element) -> WeiboPost | None:
        """
        解析单个微博卡片，提取数据
        """
        try:
            # TODO: 解析微博卡片 DOM，提取内容、作者、时间、图片等
            # 示例：
            # content_elem = await element.query_selector('p.txt')
            # content = await content_elem.inner_text() if content_elem else ""
            # ... 其他字段 ...
            return None  # 实际应返回 WeiboPost 实例
        except Exception as e:
            logger.debug(f"解析微博卡片异常: {e}")
            return None
