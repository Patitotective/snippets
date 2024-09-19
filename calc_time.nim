import std/[times, strscans, strutils]

const data = """
12:19
2:33
2:44
6:22
1:25
4:46
7:2
1:58
4:15
6:53
3:0
4:31
6:46
3:53
1:16
17:33
3:7
11:29
3:4
3:48
5:26
7:0
"""

var seconds = 0

for d in splitLines(data):
  if d.strip().len == 0: continue

  let (ok, h, m, s) = scanTuple(d, "$i:$i:$i")
  assert ok, d
  seconds += h * 60 * 60 + m * 60 + s

echo seconds, ": ", initDuration(seconds = seconds)
