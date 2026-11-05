# Bridge contract (Flutter <-> Three.js WebView)

Rule: the 3D side knows only artifact IDs and positions. All text, quizzes and translations live in Flutter.

## Flutter -> 3D  (`controller.evaluateJavascript(source: "GhostsBridge.fn(...)")`)
| Function | Purpose |
|---|---|
| `setBody(body, sites)` | Fly away, swap the planet (`'moon'`/`'mars'`), rebuild markers from `[{id,lat,lon}]`, fly back |
| `focusOn(id)` | Rotate/zoom the camera to the artifact, highlight its marker |
| `resetView()` | Zoom back out, clear highlight |
| `startTour(ids[])` | *(planned)* fly through artifacts in order |

## 3D -> Flutter  (`window.flutter_inappwebview.callHandler(name, ...args)`)
| Handler | Args | When |
|---|---|---|
| `onSceneReady` | - | Textures loaded, safe to call Flutter->3D functions |
| `onBodyReady` | `body` | Planet swap finished, markers are live |
| `onMarkerTapped` | `id` | User tapped a visible marker |
| `onCameraArrived` | `id` | `focusOn` animation finished |

## Artifact data shape (bundled JSON, read by Flutter; 3D receives only id/body/lat/lon)
```json
{
  "id": "apollo11",
  "body": "moon",
  "lat": 0.674, "lon": 23.473,
  "year": 1969,
  "type": "landing_site",
  "sources": ["https://nssdc.gsfc.nasa.gov/..."],
  "text": {
    "en": { "young": {"title": "", "story": ""}, "older": {"title": "", "story": ""} },
    "bn": { "young": {"title": "", "story": ""}, "older": {"title": "", "story": ""} }
  },
  "quiz": [
    { "en": {"q": "", "options": ["", "", ""], "answer": 0},
      "bn": {"q": "", "options": ["", "", ""], "answer": 0} }
  ]
}
```
Age tiers: `young` = under 10, `older` = 10+. Coordinates must be verified against NASA sources.
