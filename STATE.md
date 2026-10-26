# STATE — resume point

**Last updated:** 2026-10-26
**Machine:** temporary Windows box (16 GB RAM, 4 cores). Assume it will be wiped.

---

## What is actually irreplaceable

| Artifact | Size | Replaceable? |
|---|---|---|
| Original archive `GuiltyHell_A1_-_Copy.7z` | **5.34 GiB** | Only by re-downloading the game |
| This repo (notes, scripts) | 19 KB | On GitHub ✅ |
| Base extract `GuiltyHell_Base/` | 3.46 GiB | ✅ `scripts/extract-base.ps1` (~2 min) |
| Ripped project `GH_Rip/ExportedProject/` | 4.03 GiB | ✅ `scripts/rip.ps1` (~15 min) |

**Rule:** save the *archive* and the *notes*. Everything else is a build artifact.

## Where things were on disk

```
C:\Users\RDP\Downloads\
├── GuiltyHell_A1_-_Copy.7z           5.34 GiB   (source, untouched)
├── GuiltyHell_Base\                  3.46 GiB   (base game, launchable)
└── GH_Rip\ExportedProject\           4.03 GiB   (AssetRipper output)
```

Free space at time of writing: 14.3 GB of 149.9 GB.

## Done

- [x] Inventory + size analysis (`docs/01-inventory.md`)
- [x] Base-only extraction, 8.26 → 3.46 GiB
- [x] AssetRipper 2.0.0 run → full Unity project (`docs/02-assetripper-run.md`)
  - 108 scenes, 68,044 `.meta`, 4,930 C# + 48 UnityScript→C# scripts
  - `ProjectVersion.txt` = `5.4.6f3`
- [x] Blocker list + route comparison (`docs/03-blockers.md`, `docs/04-options.md`)
- [x] Repo created, private

## Not done

- [ ] **B4** — unpack `StreamingAssets/lua/luascripts` (1.13 MB UnityFS bundle) → real `.lua`
- [ ] **B1** — provision Unity 5.4.6f3 + Android module + NDK r10e + JDK 8
- [ ] **B2** — build `libslua.so` / `libEffekseerUnity.so` for arm64-v8a
- [ ] **B3** — rebuild AssetBundles for Android
- [ ] **B6** — redirect save paths to `Application.persistentDataPath`
- [ ] **B5** — touch input layer

## Next action (pick one)

**Cheapest useful step:** B4. Unpack the Lua bundle. Answers "how much game logic do I actually own?"
```powershell
python -m pip install UnityPy
python -c "import UnityPy; env=UnityPy.load(r'...\luascripts'); [print(o.type.name, o.path_id) for o in env.objects]"
```

**Go/no-go step:** B1 + B2. If Unity 5.4.6f3 cannot build an Android ARM64 player with
slua linked, the native port is dead and Winlator is the answer.

## Rebuild from zero

```powershell
.\scripts\extract-base.ps1 -Archive "C:\path\to\GuiltyHell_A1_-_Copy.7z"
.\scripts\rip.ps1 -GameData "C:\...\A1_Data" -Out "C:\...\GH_Rip"
```

Total: ~20 minutes. No prior state required.
