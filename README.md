# Guilty Hell A1 — PC→Android port experiment

Reverse-engineering / feasibility log for porting the Windows build of **Guilty Hell A1**
(Unity 5.4.6f3, Mono) to Android.

> **Status: FEASIBLE — method proven, port not started.**
> AssetRipper 2.0.0 successfully reconstructed a full, importable Unity project
> including 108 scenes and 4,978 readable scripts. Remaining blockers are enumerated
> in [`docs/03-blockers.md`](docs/03-blockers.md).

---

## TL;DR

| Question | Answer |
|---|---|
| Can a compiled Unity build become a Unity project again? | **Yes.** AssetRipper 2.0.0 did it. |
| Did UnityScript survive? | **Yes.** Translated to working C# (`UnityScript.Lang` shim). |
| Is an APK possible? | **Probably**, but it is a months-scale project, not a conversion. |
| Is there a faster path to Android? | **Yes** — Winlator (runs the Windows build as-is). See [`docs/04-options.md`](docs/04-options.md). |

## What this repo is / isn't

**Is:** findings, exact reproduction steps, blocker list, decisions. Enough to resume cold.

**Isn't:** the game, the ripped project, or any game asset. Those are copyrighted and
one file alone (`resources.assets.resS`, 1.78 GB) exceeds GitHub's 100 MB limit.
Re-rip from your own copy using [`scripts/rip.ps1`](scripts/rip.ps1).

## Source build facts

| Property | Value |
|---|---|
| Engine | **Unity 5.4.6f3** (2016) |
| Scripting backend | **Mono** (not IL2CPP — no `global-metadata.dat`) |
| Script languages | C# (`Assembly-CSharp.dll`) + **UnityScript** (`Assembly-UnityScript.dll`) |
| Native plugins | `slua.dll`, `EffekseerUnity.dll` — **x64 Windows PE only** |
| Gameplay logic | **Lua** via slua, packed in `StreamingAssets/lua/luascripts` |
| Archive | 5.34 GiB 7z → **8.26 GiB** extracted |
| Base game only | **3.46 GiB** (excludes `additional_contents`, 3.75 GiB optional) |

## Documents

1. [`docs/01-inventory.md`](docs/01-inventory.md) — size/asset breakdown, what's removable
2. [`docs/02-assetripper-run.md`](docs/02-assetripper-run.md) — exact procedure + results
3. [`docs/03-blockers.md`](docs/03-blockers.md) — what still stands between this and an APK
4. [`docs/04-options.md`](docs/04-options.md) — port vs. Winlator, effort estimates

## Reproduce

```powershell
# 1. extract base game only (3.46 GiB)
.\scripts\extract-base.ps1 -Archive "C:\path\to\GuiltyHell_A1.7z"

# 2. rip to a Unity project (~4 GiB, 108 scenes)
.\scripts\rip.ps1 -GameData "C:\path\to\A1_Data" -Out "C:\path\to\GH_Rip"
```

## Toolchain used

- AssetRipper **2.0.0** (`AssetRipper_win_x64.zip`, GUI web server, `--headless --port`)
- 7-Zip (extraction, `-xr!` excludes)
- PowerShell 7 on Windows

## Licence / provenance

No game code or assets are stored here. Analysis notes only.
The game remains the property of its developers; this is interoperability research
on software the operator owns.
