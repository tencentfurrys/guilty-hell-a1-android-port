# 02 — AssetRipper run (the experiment)

**Result: SUCCESS.** A full Unity project was reconstructed from the shipped Windows build.

## Tool

AssetRipper **2.0.0** — `AssetRipper_win_x64.zip` (42.4 MB).
The release is GUI-only; the GUI is a local web server, so it is fully scriptable.

```powershell
AssetRipper.GUI.Free.exe --headless --port 8123
```

It exposes OpenAPI at `http://localhost:8123/openapi.json` and Swagger at `/swagger`.
Relevant endpoints, all `application/x-www-form-urlencoded`:

| Endpoint | Field | Purpose |
|---|---|---|
| `POST /LoadFolder` | `path` | load game data dir (`...\A1_Data`) |
| `POST /Export/UnityProject` | `path`, `CreateSubfolder` | full project export |
| `POST /Export/PrimaryContent` | `path`, `CreateSubfolder` | raw assets only |

> Pitfall: the form field is lowercase **`path`**. `Path` happens to bind, but use `path`.
> The export POST does not return until finished — a 60s HTTP timeout aborts the
> *request* but the export continues in-process. Poll the output folder instead.

It auto-detected `5.4.6f3` and offered `unityhub://5.4.6f3`.

## Resource use

| Metric | Value |
|---|---|
| Load phase | ~60 s CPU, 7.3 GB RSS |
| Export phase | ~300 s CPU, ~7 GB RSS |
| Output | **4.03 GiB**, **137,025 files** |
| Host | 16 GB RAM, 4 logical cores |

## What came out

```
ExportedProject/
├── Assets/
│   ├── Scripts/
│   │   ├── Assembly-CSharp/        4,930 files  (6.44 MB source)
│   │   └── Assembly-UnityScript/      48 files  (UnityScript -> C#)
│   ├── Scenes/                       108 .unity  (480 MB)
│   ├── Texture2D/                    1.65 GB
│   ├── StreamingAssets/              625 MB
│   ├── Resources/                    416 MB
│   ├── AudioClip/                    6.6 MB
│   └── Plugins/                      Arbor FSM, Effekseer API, Standard Assets, Image Effects
├── Packages/
└── ProjectSettings/ProjectVersion.txt -> m_EditorVersion: 5.4.6f3
```

**68,044 `.meta` files** — the project is properly structured for a Unity import.

## Script quality — the critical finding

### UnityScript decompiled cleanly

`Assembly-UnityScript/ParticleSpawner.cs`:

```csharp
using UnityScript.Lang;

public class ParticleSpawner : MonoBehaviour
{
    public GameObject[] particles;
    ...
    public virtual void Start()
    {
        System.Array.Sort(particles, (g1, g2) => string.Compare(g1.name, g2.name));
        pages = (int)Mathf.Ceil((Extensions.get_length((System.Array)particles) - 1) / maxButtons);
    }
}
```

Readable, compilable C#. It depends on the `UnityScript.Lang` runtime shim
(`Extensions.get_length`, etc.) — either ship that assembly or rewrite those calls
to `Array.Length` / `List.Count`. Mechanical work, not a blocker.

### C# decompiled cleanly

`Assembly-CSharp/SaveManager.cs` — real structure, real identifiers, 4,930 files.
Example confirms `IkoGameSystem`, `TimeSystem`, `SingletonMonoBehaviour<T>` namespaces
all survived.

## Lua: not yet extracted

`StreamingAssets/lua/luascripts` is **1.13 MB and is itself a UnityFS bundle**
(header: `UnityFS  5.x.x  5.4.6f3`, `CAB-106e...`), not plain text. The gameplay
logic is TextAssets inside it. AssetRipper passes StreamingAssets through opaquely.

**Next step:** unpack that bundle with UnityPy or AssetRipper's bundle view to recover
the `.lua` sources. Until then, the exact gameplay logic is not auditable.

## Bundles in the rip

`Assets/StreamingAssets/bundles/` contains **17** base-game bundles, all UnityFS 5.4.6f3,
Windows-targeted. They will not load on Android and must be rebuilt from the ripped
project (see blockers).
