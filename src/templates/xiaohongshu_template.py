"""
Hunter AI 内容工厂 - 小红书内容模板

功能：
- 采集小红书热门内容
- 生成种草推荐/测评对比/攻略指南类文章
- 全自动执行：采集 → 分析 → 生成 → 推送

使用方法：
    from src.templates import get_template
    template = get_template("xhs")
    result = await template.run()
"""

from src.templates import BaseTemplate, TemplateResult, register_template
from src.intel.utils import get_output_path, get_today_str, push_to_wechat
from src.config import settings
from rich.console import Console

console = Console()


@register_template("xhs")
class XiaohongshuTemplate(BaseTemplate):
    """
    小红书内容模板

    流程：
    1. 通过 Playwright 采集小红书热门笔记
    2. AI 分析提炼核心内容
    3. 生成公众号风格文章
    4. 推送到微信
    """

    name = "xhs"
    description = "小红书热门 - 采集热门笔记生成种草文章"
    requires_intel = True

    def __init__(self, keyword: str = "AI 工具", count: int = 10):
        """
        初始化模板

        Args:
            keyword: 搜索关键词
            count: 采集数量
        """
        super().__init__()
        self.keyword = keyword
        self.count = count

    async def run(self) -> TemplateResult:
        """执行小红书内容采集流程"""
        self.print_header()

        try:
            from src.intel.xiaohongshu_hunter import XiaohongshuHunter

            # 运行小红书猎手
            console.print(f"[cyan]📱 启动小红书采集: {self.keyword}[/cyan]")
            hunter = XiaohongshuHunter()

            # 检查是否已配置 Cookie
            if not hunter.is_logged_in():
                console.print("[yellow]⚠️ 未配置小红书 Cookie[/yellow]")
                console.print("[cyan]   请在 config.yaml 中配置 xiaohongshu.cookies[/cyan]")
                console.print("[dim]   获取方法: 浏览器登录小红书 → F12 → Application → Cookies → 复制[/dim]")
                return TemplateResult(
                    success=False,
                    title="",
                    content="",
                    output_path="",
                    push_status="失败",
                    error="未配置小红书 Cookie，请在 config.yaml 中配置 xiaohongshu.cookies",
                )

            result = await hunter.run(keyword=self.keyword, count=self.count)

            if result.get("success"):
                return TemplateResult(
                    success=True,
                    title=result.get("article_title", ""),
                    content=result.get("article_content", ""),
                    output_path=result.get("output_path", ""),
                    push_status="已推送" if settings.push.enabled else "未推送",
                )
            else:
                return TemplateResult(
                    success=False,
                    title="",
                    content="",
                    output_path="",
                    push_status="失败",
                    error=result.get("error", "采集失败"),
                )

        except ImportError as e:
            console.print(f"[red]❌ 模块导入失败: {e}[/red]")
            console.print("[yellow]   请确保已安装 Playwright:[/yellow]")
            console.print("[cyan]   uv sync && uv run playwright install chromium[/cyan]")
            return TemplateResult(
                success=False,
                title="",
                content="",
                output_path="",
                push_status="失败",
                error=f"Playwright 未安装: {e}",
            )

        except Exception as e:
            console.print(f"[red]❌ 小红书模板执行失败: {e}[/red]")
            return TemplateResult(
                success=False,
                title="",
                content="",
                output_path="",
                push_status="失败",
                error=str(e),
            )
