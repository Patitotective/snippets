import std/[times, strscans, strutils]

const data = """

"""

var seconds = 236899

for d in splitLines(data):
  if d.strip().len == 0: continue

  let (ok, h, m, s) = scanTuple(d, "$i:$i:$i")
  assert ok, d
  seconds += h * 60 * 60 + m * 60 + s

echo seconds, ": ", initDuration(seconds = seconds)
