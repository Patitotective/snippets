const trajectoryStrokeStyles = ["Orange", "Salmon", "Crimson", "Pink", "HotPink", "Tomato", 
  "Gold", "Khaki", "Violet", "SlateBlue", "YellowGreen", "LightSeaGreen", 
  "SkyBlue"]

var a: array[trajectoryStrokeStyles.len, string]

for e in countdown(trajectoryStrokeStyles.high, trajectoryStrokeStyles.low):
  a[trajectoryStrokeStyles.high - e] = trajectoryStrokeStyles[e]

echo a
