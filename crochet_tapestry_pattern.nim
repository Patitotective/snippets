import std/[tables, strformat, strutils]
import pixie
import chroma

type
  SectionKind = enum
    skStitches, skQuarter

  Section = object
    case kind*: SectionKind
    of skStitches:
      color*: ColorRGBX
      repeated*: int
    of skQuarter:
      discard

proc stiches(color: ColorRGBX, repeated: int): Section = 
  Section(kind: skStitches, color: color, repeated: repeated)

proc quarter(): Section = 
  Section(kind: skQuarter)

const
  colorsTable = {
    rgbx(0, 0, 0, 255): "black", 
    rgbx(250, 226, 121, 255): "yellow", # skin 
    rgbx(255, 86, 36, 255): "orange", # hair
    rgbx(254, 243, 213, 255): "crudo", # spots on the face
    rgbx(255, 15, 24, 255): "red", # lips
    rgbx(255, 144, 105, 255): "salmon", # inside mouth
    rgbx(0, 211, 67, 255): "dark green", # hair
    rgbx(63, 208, 246, 255): "light blue", # hair
    rgbx(255, 105, 221, 255): "pink", # hair
    rgbx(255, 255, 255, 255): "white", # lighting
    rgbx(255, 43, 233, 255): "magenta", #lips
    rgbx(255, 156, 241, 255): "lila", # spots on the lips
    rgbx(237, 131, 255, 255): "purple", # spots on the lips
    rgbx(255, 153, 167, 255): "light orange" # inside mouth
  }.toTable

proc str(col: ColorRGBX): string = 
  if col in colorsTable:
    colorsTable[col]
  else:
    &"rgbx({col.r}, {col.g}, {col.b}, {col.a})"

iterator pairs[T](s: openArray[T], reversed: bool): (int, T) =
  if reversed:
    for i in countdown(s.high, s.low):
      yield (s.high - i, s[i])
  else:
    for i in countup(s.low, s.high):
      yield (i, s[i])

let image = readImage("/home/cristobal/Sync/Chu chu song 128.png")
var rows = newSeq[seq[Section]]()

for y in 0..<image.height:
  #if y > 10: continue
  var row = @[quarter()]

  for x in 0..<image.width:
    let pxc = image[x, y]

    # If the pixel before this one is the same color increase the previous stitch's repeated
    if row.len > 0 and row[^1].kind == skStitches and 
      row[^1].color == pxc:
      inc row[^1].repeated
    else:
      row.add stiches(pxc, 1)

    # Add a quarter every quarter
    if (x + 1) mod (image.width div 4) == 0:
      row.add quarter()

  rows.add row

var pattern = ""
let rowsSep = image.width div 16

for (rowCount, row) in rows.pairs(reversed = true):
  #if rowCount != 111: continue

  if rowCount == 0 or (rowCount) mod rowsSep == 0:
    pattern.add &"{(rowCount div rowsSep)+1}/16\n"

  pattern.add &"  {rowCount+1}.\n"

  var stichesCount = 0 # Sections of kind stitches
  var quarterCount = 0
  var stitchesPerQuarterCount = 0
  for (colCount, col) in row.pairs(reversed = rowCount mod 2 == 0):
    case col.kind
    of skStitches:
      if col.color notin colorsTable:
        echo &"unknown color at {stichesCount+col.repeated-1}, {rowCount}: {col.color}"

      pattern.add &"{' '.repeat(6)}{stitchesPerQuarterCount+1}. In {col.color.str}"

      if rowCount == 0 and colCount == 0: # First row and first column
        pattern.add &", ch{image.width+1}, sk ch"
      elif rowCount > 0 and colCount == 0: # Not first row and first column
        pattern.add ", ch, sk ch"

      pattern.add &", sc{col.repeated}\n"

      inc stichesCount
      inc stitchesPerQuarterCount
    of skQuarter:
      #pattern.add &"\n  {((col.quarter + 1) * (image.width div 4))}/{image.width} completed"
      stitchesPerQuarterCount = 0
      if quarterCount >= 4:
        #pattern.add "\n"
        break

      pattern.add &"{' '.repeat(4)}{quarterCount+1}/4\n"
      inc quarterCount

  #pattern.add &" ({image.width})\n"

echo pattern
#for s in rows[rows.high - 111]:
#  echo s
