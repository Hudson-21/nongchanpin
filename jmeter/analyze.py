# -*- coding: utf-8 -*-
"""
解析 JMeter .jtl 结果文件，计算平均响应时间、P95/P99、吞吐量、错误率
用法: python analyze.py <jtl文件> [场景名]
"""
import csv
import sys
import os
from collections import defaultdict


def percentile(sorted_vals, p):
    if not sorted_vals:
        return 0
    k = (len(sorted_vals) - 1) * p / 100.0
    f = int(k)
    c = min(f + 1, len(sorted_vals) - 1)
    if f == c:
        return sorted_vals[f]
    return sorted_vals[f] + (sorted_vals[c] - sorted_vals[f]) * (k - f)


def analyze(jtl_path, scenario=""):
    rows = []
    with open(jtl_path, "r", encoding="utf-8", errors="ignore") as f:
        reader = csv.DictReader(f)
        for r in reader:
            if not r.get("timeStamp"):
                continue
            rows.append(r)

    if not rows:
        return {"scenario": scenario, "error": "no data"}

    ts = [int(r["timeStamp"]) for r in rows]
    start, end = min(ts), max(ts)
    duration = (end - start) / 1000.0

    groups = defaultdict(list)
    for r in rows:
        groups[r["label"]].append(r)

    result = {
        "scenario": scenario,
        "total_samples": len(rows),
        "duration_sec": round(duration, 1),
        "overall": {},
        "by_label": [],
    }

    all_elapsed = []
    all_err = 0
    label_stats = []
    for label, rs in groups.items():
        elapsed = sorted(int(r["elapsed"]) for r in rs)
        err = sum(1 for r in rs if r.get("success", "true").lower() != "true")
        all_elapsed += elapsed
        all_err += err
        label_stats.append({
            "label": label,
            "samples": len(rs),
            "avg": round(sum(elapsed) / len(elapsed), 1),
            "min": elapsed[0],
            "max": elapsed[-1],
            "p95": round(percentile(elapsed, 95), 1),
            "p99": round(percentile(elapsed, 99), 1),
            "throughput": round(len(rs) / duration, 2) if duration > 0 else 0,
            "error_rate": round(err * 100.0 / len(rs), 2),
            "errors": err,
        })
    label_stats.sort(key=lambda x: x["label"])

    all_sorted = sorted(all_elapsed)
    result["by_label"] = label_stats
    result["overall"] = {
        "samples": len(all_elapsed),
        "avg": round(sum(all_elapsed) / len(all_elapsed), 1),
        "min": all_sorted[0],
        "max": all_sorted[-1],
        "p95": round(percentile(all_sorted, 95), 1),
        "p99": round(percentile(all_sorted, 99), 1),
        "throughput": round(len(all_elapsed) / duration, 2) if duration > 0 else 0,
        "error_rate": round(all_err * 100.0 / len(all_elapsed), 2),
        "errors": all_err,
    }
    return result


def print_result(res):
    if "error" in res:
        print(res)
        return
    print("=" * 90)
    print(f"场景: {res['scenario']}  样本数: {res['total_samples']}  时长: {res['duration_sec']}s")
    o = res["overall"]
    print(f"总体: 平均 {o['avg']}ms  P95 {o['p95']}ms  P99 {o['p99']}ms  "
          f"最大 {o['max']}ms  吞吐量 {o['throughput']}/s  错误率 {o['error_rate']}% ({o['errors']})")
    print("-" * 90)
    print(f"{'接口/业务':<34}{'样本':>6}{'平均':>9}{'P95':>9}{'P99':>9}{'最大':>9}{'吞吐/s':>9}{'错误率':>9}")
    for l in res["by_label"]:
        print(f"{l['label'][:33]:<34}{l['samples']:>6}{l['avg']:>9}{l['p95']:>9}"
              f"{l['p99']:>9}{l['max']:>9}{l['throughput']:>9}{l['error_rate']:>8}%")
    print("=" * 90)


if __name__ == "__main__":
    path = sys.argv[1]
    name = sys.argv[2] if len(sys.argv) > 2 else os.path.basename(path)
    print_result(analyze(path, name))
