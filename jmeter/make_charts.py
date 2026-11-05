# -*- coding: utf-8 -*-
"""生成压力测试报告所需的趋势图 PNG（无需联网，使用本机 matplotlib + 系统中文字体）"""
import os, csv, io, math
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager

OUT = r"E:\nongchanpin\jmeter\screenshots"
os.makedirs(OUT, exist_ok=True)

# ---- 中文字体 ----
FONT = None
for p in [r"C:\Windows\Fonts\msyh.ttc", r"C:\Windows\Fonts\msyh.ttf",
          r"C:\Windows\Fonts\simhei.ttf", r"C:\Windows\Fonts\simsun.ttc"]:
    if os.path.exists(p):
        FONT = font_manager.FontProperties(fname=p)
        break
if FONT is not None:
    plt.rcParams["axes.unicode_minus"] = False
else:
    print("WARN: no CJK font found")

def save(fig, name, tight=True):
    path = os.path.join(OUT, name)
    fig.savefig(path, dpi=150, bbox_inches="tight" if tight else None,
                facecolor="white")
    plt.close(fig)
    print("saved:", path)

def T(s):
    """中文标题"""
    return s

# ============================================================
# 数据（来自 results/summary-FINAL2.txt，由 .jtl 统计得出）
# ============================================================
scen = ["S1", "S2", "S3", "S4"]
conc = [20, 50, 100, 200]
avg  = [13.8, 34.6, 64.9, 95.7]
p95  = [103.0, 293.0, 556.0, 853.0]
p99  = [148.9, 428.0, 878.0, 1256.8]
tps  = [1386.4, 1386.9, 1480.5, 2013.0]
err  = [0.0, 0.0, 0.0, 0.0]

# ---- 图 6-1 并发数—响应时间趋势 ----
fig, ax = plt.subplots(figsize=(8, 4.6))
ax.plot(conc, avg, "o-", color="#c0392b", linewidth=2, markersize=7, label=T("平均响应时间"))
ax.plot(conc, p95, "s-", color="#e67e22", linewidth=2, markersize=7, label="P95 响应时间")
ax.plot(conc, p99, "^--", color="#8e44ad", linewidth=2, markersize=7, label="P99 响应时间")
# 仅在 200 并发端点标注数值，避免重叠
for ys, c, fmt in [(avg, "#c0392b", "%.1f"), (p95, "#e67e22", "%.0f"), (p99, "#8e44ad", "%.0f")]:
    ax.annotate(fmt % ys[-1], (conc[-1], ys[-1]), xytext=(8, 0),
                textcoords="offset points", ha="left", va="center", fontsize=10, color=c)
ax.set_yscale("log")
ax.set_yticks([10, 20, 50, 100, 200, 500, 1000])
ax.get_yaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax.set_xlim(10, 260)
ax.set_xlabel(T("并发用户数（线程数）"), fontproperties=FONT, fontsize=11)
ax.set_ylabel(T("响应时间（ms，对数坐标）"), fontproperties=FONT, fontsize=11)
ax.set_title(T("图 6-1  并发数—响应时间趋势"), fontproperties=FONT, fontsize=13, pad=14)
ax.set_xticks(conc)
ax.grid(True, which="both", linestyle=":", alpha=0.5)
ax.legend(prop=FONT, fontsize=10, loc="center right")
fig.tight_layout()
save(fig, "图6-1_并发数-响应时间趋势.png", tight=False)

# ---- 图 6-2 并发数—错误率趋势 ----
fig, ax = plt.subplots(figsize=(8, 4.2))
bars = ax.bar([str(c) for c in conc], err, color="#27ae60", width=0.5)
ax.set_ylim(0, 1.0)
for b in bars:
    ax.annotate("0.00%", (b.get_x() + b.get_width() / 2, 0.02), ha="center", fontsize=10)
ax.set_xlabel(T("并发用户数（线程数）"), fontproperties=FONT, fontsize=11)
ax.set_ylabel(T("错误率（%）"), fontproperties=FONT, fontsize=11)
ax.set_title(T("图 6-2  并发数—错误率趋势（全部场景错误率 0.00%）"), fontproperties=FONT, fontsize=13, pad=14)
ax.grid(True, axis="y", linestyle=":", alpha=0.6)
save(fig, "图6-2_并发数-错误率趋势.png")

# ---- 图 6-3 并发数—吞吐量趋势 ----
fig, ax = plt.subplots(figsize=(8, 4.6))
ax.plot(conc, tps, "o-", color="#2980b9", linewidth=2.2, markersize=8, label=T("吞吐量"))
for x, y in zip(conc[1:], tps[1:]):
    ax.annotate("%.1f" % y, (x, y), xytext=(0, 10), textcoords="offset points",
                ha="center", fontsize=10, color="#2980b9")
ax.set_xlabel(T("并发用户数（线程数）"), fontproperties=FONT, fontsize=11)
ax.set_ylabel(T("吞吐量（requests/second）"), fontproperties=FONT, fontsize=11)
ax.set_title(T("图 6-3  并发数—吞吐量趋势"), fontproperties=FONT, fontsize=13, pad=14)
ax.set_xticks(conc)
ax.set_ylim(0, max(tps) * 1.25)
ax.grid(True, linestyle=":", alpha=0.6)
ax.legend(prop=FONT, fontsize=10)
save(fig, "图6-3_并发数-吞吐量趋势.png")

# ---- 图 6-4 分接口平均响应时间对比（各并发档） ----
labels = ["首页", "商品列表", "商品详情", "商品搜索", "公告列表", "留言板", "会员登录"]
per = {
    "S1(20)": [2.6, 2.7, 3.0, 2.2, 2.4, 3.2, 80.5],
    "S2(50)": [2.6, 2.7, 3.1, 2.2, 2.4, 3.3, 225.8],
    "S3(100)": [2.7, 2.8, 3.1, 2.2, 2.5, 3.3, 437.8],
    "S4(200)": [2.5, 2.6, 2.9, 2.1, 2.3, 3.1, 654.2],
}
fig, ax = plt.subplots(figsize=(9, 4.8))
x = range(len(labels))
w = 0.2
colors = ["#3498db", "#16a085", "#f39c12", "#c0392b"]
for i, (k, v) in enumerate(per.items()):
    ax.bar([xi + (i - 1.5) * w for xi in x], v, width=w, label=k, color=colors[i])
ax.set_yscale("log")
ax.set_ylabel(T("平均响应时间（ms，对数坐标）"), fontproperties=FONT, fontsize=11)
ax.set_title(T("图 6-4  各接口平均响应时间对比（会员登录为唯一瓶颈）"), fontproperties=FONT, fontsize=13, pad=14)
ax.set_xticks(list(x))
ax.set_xticklabels(labels, fontproperties=FONT, fontsize=10)
ax.grid(True, axis="y", linestyle=":", alpha=0.6)
ax.legend(prop=FONT, fontsize=10)
save(fig, "图6-4_各接口平均响应时间对比.png")

# ---- 图 5-1 业务流程各步骤响应时间 ----
steps = ["1 会员登录", "2 浏览首页", "3 商品详情", "4 加入购物车", "5 查看购物车", "6 退出登录"]
sv = [15.9, 4.9, 5.9, 8.4, 15.4, 9.9]
fig, ax = plt.subplots(figsize=(8.5, 4.4))
b = ax.barh(steps[::-1], sv[::-1], color="#2980b9", height=0.55)
for r, v in zip(b, sv[::-1]):
    ax.annotate("%.1f ms" % v, (v + 0.3, r.get_y() + r.get_height() / 2), va="center", fontsize=10)
ax.set_xlabel(T("平均响应时间（ms）"), fontproperties=FONT, fontsize=11)
ax.set_title(T("图 5-1  完整业务流程各步骤平均响应时间（10 并发 × 5 次）"), fontproperties=FONT, fontsize=13, pad=14)
ax.set_xlim(0, max(sv) * 1.25)
ax.grid(True, axis="x", linestyle=":", alpha=0.6)
ax.set_yticklabels(steps[::-1], fontproperties=FONT, fontsize=10)
save(fig, "图5-1_业务流程各步骤响应时间.png")

# ---- 图 6-5 S6 持续压力：响应时间随时间变化（直接从 S6.jtl 计算） ----
jtl = r"E:\nongchanpin\jmeter\results\S6.jtl"
if os.path.exists(jtl):
    rows = []
    with io.open(jtl, "r", encoding="utf-8", errors="ignore") as f:
        rd = csv.DictReader(f)
        t0 = None
        for r in rd:
            try:
                ts = int(r["timeStamp"])
                el = float(r["elapsed"])
            except Exception:
                continue
            if t0 is None:
                t0 = ts
            rows.append(((ts - t0) / 1000.0, el, r.get("success", "true") == "true"))
    if rows:
        dur = max(r[0] for r in rows)
        bucket = 10
        nb = int(dur // bucket) + 1
        sums = [0.0] * nb
        cnts = [0] * nb
        errs = [0] * nb
        for t, el, ok in rows:
            i = min(int(t // bucket), nb - 1)
            sums[i] += el
            cnts[i] += 1
            if not ok:
                errs[i] += 1
        xs = [i * bucket + bucket / 2.0 for i in range(nb) if cnts[i] > 0]
        ys = [sums[i] / cnts[i] for i in range(nb) if cnts[i] > 0]
        tp = [cnts[i] / float(bucket) for i in range(nb) if cnts[i] > 0]

        fig, ax1 = plt.subplots(figsize=(9, 4.6))
        ax1.plot(xs, ys, "o-", color="#c0392b", linewidth=2, markersize=5, label=T("平均响应时间"))
        ax1.set_xlabel(T("运行时间（秒）"), fontproperties=FONT, fontsize=11)
        ax1.set_ylabel(T("平均响应时间（ms）"), fontproperties=FONT, fontsize=11, color="#c0392b")
        ax1.tick_params(axis="y", labelcolor="#c0392b")
        ax1.grid(True, linestyle=":", alpha=0.6)
        ax2 = ax1.twinx()
        ax2.plot(xs, tp, "s--", color="#2980b9", linewidth=1.8, markersize=4, label=T("吞吐量"))
        ax2.set_ylabel(T("吞吐量（requests/second）"), fontproperties=FONT, fontsize=11, color="#2980b9")
        ax2.tick_params(axis="y", labelcolor="#2980b9")
        ax1.set_title(T("图 6-5  S6 持续压力场景：响应时间与吞吐量随时间变化（50 并发 / 120 秒）"),
                      fontproperties=FONT, fontsize=12.5, pad=14)
        h1, l1 = ax1.get_legend_handles_labels()
        h2, l2 = ax2.get_legend_handles_labels()
        ax1.legend(h1 + h2, l1 + l2, prop=FONT, fontsize=10, loc="upper left")
        save(fig, "图6-5_S6持续压力响应时间随时间变化.png")

print("ALL DONE")
