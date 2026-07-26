#!/usr/bin/env python3
"""Pattern 5: Braille dots - dotted progress bar using braille characters"""
import json, os, subprocess, sys
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def braille_bar(pct, width=8):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar

def fmt(label, pct):
    p = round(pct)
    return f'{DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%'

def fmt_plain(label, value):
    return f'{DIM}{label}{R} {value}'

def git_output(cwd, *args):
    try:
        r = subprocess.run(
            ('git', *args), cwd=cwd, timeout=1,
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return r.stdout.strip() if r.returncode == 0 else None

def git_branch(cwd):
    """cwd のブランチ名。detached HEAD は短縮 SHA、git 管理外は None。"""
    if not cwd or not os.path.isdir(cwd):
        return None
    name = git_output(cwd, 'symbolic-ref', '--quiet', '--short', 'HEAD')
    if name:
        return name if len(name) <= 30 else name[:29] + '…'
    sha = git_output(cwd, 'rev-parse', '--short', 'HEAD')
    return f'@{sha}' if sha else None

def fmt_count(n):
    if n < 1000:
        return str(n)
    elif n < 1000000:
        return f'{n / 1000:.1f}k'
    else:
        return f'{n / 1000000:.1f}M'

model = data.get('model', {}).get('display_name', 'Claude')
parts = [model]

branch = git_branch(data.get('workspace', {}).get('current_dir') or data.get('cwd'))
if branch:
    parts.append(fmt_plain('git', branch))

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('ctx', ctx))

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    parts.append(fmt('5h', five))

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt('7d', week))

input_tokens = data.get('context_window', {}).get('total_input_tokens')
output_tokens = data.get('context_window', {}).get('total_output_tokens')
if input_tokens is not None and output_tokens is not None:
    parts.append(fmt_plain('tok', fmt_count(input_tokens + output_tokens)))

cost = data.get('cost', {}).get('total_cost_usd')
if cost is not None:
    parts.append(fmt_plain('cost', f'${cost:.4f}'))

print(f' {DIM}│{R} '.join(parts), end='')
