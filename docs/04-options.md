# 04 — Route comparison

## Route A — Winlator (run the Windows build on Android)

**Effort: hours. Risk: low. Output: no APK, but the game runs.**

Winlator runs Windows x86_64 applications on Android via Wine + Box86/Box64.
It is MIT-licensed and actively forked.

- Official: https://winlator.org / https://github.com/brunodev85/winlator
- **Unity-specific:** set the Box64 preset to `Stability (Unity Games)`
- **Also try:** exec argument `-force-gfx-direct`
- Alternative runtimes in the same family: OpenNative, GameHub, WineBox

Recommended first attempt, in this order:

1. Install Winlator, create a container (Windows 7, 64-bit).
2. Copy the **3.46 GiB base game** (not the 8.26 GiB full extract).
3. Launch `A1.exe`; if unstable, switch Box64 preset to `Stability (Unity Games)`.
4. If black screen, add `-force-gfx-direct`.

**"Custom VM runner" note:** building a Wine/Box64-class translator from scratch is a
multi-year team effort and is strictly worse than forking the existing MIT project.
If a custom runner is wanted, fork Winlator and ship presets — that is a launcher, not a VM.

## Route B — Native Android port (this repo's subject)

**Effort: months. Risk: high. Output: real APK.**

Proven viable by AssetRipper. Reference implementation for the *method*:
`tencentfurrys/mkm-android-port` — a one-off port of Mystic Knight Maya 0.7.5
(Unity 2019.2.6f1, C#). That repo is **not a tool**; nothing in it is reusable except
the workflow. It is worth reading for its patch list (P0 save paths, P1 JSON loading,
P1g audio memory OOM fix, P2 touch input).

### Why Guilty Hell is a harder target than MKM

| | Mystic Knight Maya | Guilty Hell A1 |
|---|---|---|
| Unity | 2019.2.6f1 | **5.4.6f3** (2016) |
| Scripts | C# only | C# + **UnityScript** |
| Scripting runtime | Mono | Mono + **slua (Lua)** |
| Content model | 33 scenes in-build | **200 external AssetBundles** |
| Native plugins | rebuildable | slua + Effekseer, x64 only |
| Size | ~1–2 GB | 8.26 GB (3.46 GB base) |

The UnityScript problem turned out to be **smaller than feared** — AssetRipper emitted
compilable C#. The bundle-rebuild problem (B3) is now the largest technical risk.

## Route C — Split into parts / modular install

Not a compression technique, but it is the practical answer to "make it fit":

- The game is *already* modular: `additional_contents` is ~200 independently loaded bundles.
- Keep `3.46 GiB` base; pull individual bundles back from the archive on demand.
- Splitting an APK (AAB config splits / Play Asset Delivery) reduces *per-device download*,
  never total size. With one ABI and one locale there is nothing to split.

## Route D — "Make Unity build as small as possible"

Only meaningful once a project exists (Route B). Levers, in order of payoff:

1. **Audio → Vorbis.** The 2.46 GiB of `.resS` is PCM. This is the single biggest win (~1.5–2 GiB).
2. **Texture re-import** at target resolution, BC7/ETC2, Crunch off (it is slow for little gain).
3. **Mesh compression** Medium/High.
4. **Managed stripping** + `Strip Engine Code`.
5. **Remove unused assets** — but only after the Lua layer is readable (B4).

Realistic floor: **~2 GB**, dominated by art and audio. The `.kkrieger` 96 KB comparison
is not applicable — that game stores no assets at all; it regenerates them procedurally.

## Recommendation

1. **Today:** Winlator + the 3.46 GiB base game. Zero porting.
2. **If a real APK is required:** start at B1 (toolchain) and B2 (native `.so`).
   Those two decide go/no-go. Do not invest in bundle rebuilding until both are green.
