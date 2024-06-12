import std/[httpclient, strformat, json, os, strutils]
from std/base64 import nil

const
  clientId = ""
  clientSecret = ""
  playlistId = ""

createDir("y")

var client = newHttpClient()

proc authHeaders(accessToken: JsonNode): HttpHeaders = 
  newHttpHeaders({"Authorization": &"Bearer {accessToken.getStr}"})

proc normalizeFilename(s: string): string = 
  ## Normalizes any string so that it becomes a valid filename in Windows and Linux
  result = s.strip().multiReplace({
    "\0": "", "/": "", "\\": "", ":", "", "*": "", 
    "?": "", "\"": "", "<": "", ">": "", "|": ""
  })

  if result.len == 0 or result == "." or result == "..":
    return "invalid"

try:
  let credentialsResponse = client.request(
    "https://accounts.spotify.com/api/token", 
    httpMethod = HttpPost, 
    headers = newHttpHeaders({
      "Content-Type": "application/x-www-form-urlencoded", 
      "Authorization": "Basic " & base64.encode(&"{clientId}:{clientSecret}")
    }),
    body = "grant_type=client_credentials"
  )
  
  #echo (s: credentialsResponse.status, h: credentialsResponse.headers, b: credentialsResponse.body())
  assert credentialsResponse.status == "200 OK"

  let
    credentialsBody = parseJson(credentialsResponse.body())
    accessToken = credentialsBody["access_token"]
    tokenType = credentialsBody["token_type"]

  client.headers = authHeaders(accessToken)

  let tracks = newJArray()
  var offset = 128

  while true:
    let tracksResponse = client.request(
      &"https://api.spotify.com/v1/playlists/{playlistId}/tracks?playlist_id={playlistId}&limit=50&offset={offset}",
      httpMethod = HttpGet, 
      headers = authHeaders(accessToken)
    )
    #echo (s: tracksResponse.status, h: tracksResponse.headers)
    let tracksBody = parseJson(tracksResponse.body())
    #echo tracksBody

    if tracksBody["items"].len == 0:
      break

    for item in tracksBody["items"].getElems:
      let track = item["track"]
      #echo (ntrack: t)
      echo offset

      let filename = track["name"].getStr.normalizeFilename()
      let images = track["album"]["images"]

      if images.len > 0:
        try:
            client.downloadFile(images[0]["url"].getStr, &"images/{filename}")
        except:
          echo filename, "[X]: ", track["album"]["images"][0]["url"].getStr
      else:
        echo filename, "[X]: has no images"


      tracks.add track
      inc offset

finally:
  client.close()
