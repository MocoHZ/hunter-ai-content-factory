"""
微博热搜 Tab
展示微博热搜榜内容
"""

import gradio as gr
from src.intel.weibo_hunter import WeiboHunter
import asyncio


async def fetch_weibo_hot():
    hunter = WeiboHunter()
    topics = await hunter.get_hot_topics()
    return [f"{t.title}（热度：{t.hot_value}）" for t in topics]


def create_weibo_tab():
    """创建微博热搜 Tab"""
    with gr.TabItem("🐦 微博热搜"):
        gr.Markdown("### 微博热搜榜")
        hot_list = gr.State([])
        gr.Button("刷新热搜", elem_id="weibo-refresh").click(lambda: asyncio.run(fetch_weibo_hot()), None, hot_list)
        gr.List(hot_list, label="当前热搜榜", elem_id="weibo-hot-list")
