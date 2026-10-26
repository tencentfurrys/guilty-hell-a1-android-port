# 03 — Remaining blockers

Ordered by severity. Each is a concrete task, not an unknown.

## B1 — Unity 5.4.6f3 editor + Android toolchain  *(hard prerequisite)*

Unity 5.4.6f3 is from 2016. It is still in Unity's download archive, but:

- Requires **Android Build Support** for that exact version (5.4 era).
- Requires an **ancient NDK** (r10e / r11c). Modern NDK r2x will not link.
- Requires **JDK 8**; modern JDKs break the 5.4 build pipeline.
- `ProjectVersion.txt` pins `5.4.6f3` — opening in any other version triggers a
  destructive upgrade that will not round-trip back.

**Action:** provision a clean VM with Unity 5.4.6f3 + Android module + NDK r10e + JDK 8
before touching anything else. Everything downstream depends on this working.

## B2 — Native plugins have no Android build

| Plugin | Present | Needed |
|---|---|---|
| `slua.dll` | x64 Windows PE | `libslua.so` arm64-v8a |
| `EffekseerUnity.dll` | x64 Windows PE | `libEffekseerUnity.so` arm64-v8a |

Both upstreams are open source (slua; Effekseer UnityPlugin), so ARM64 `.so` builds are
possible — but they must match the 5.4-era plugin ABI and the C# wrapper signatures in
`Assets/Plugins/`.

**Risk:** slua is the *scripting runtime*. Without it, nothing in the Lua layer runs.

## B3 — AssetBundles are Windows-targeted

The 17 base bundles (534 MB) + all `additional_contents` bundles were built for
StandaloneWindows. Unity bundles bake target platform (texture format, shader variants)
and refuse to load cross-platform.

**Action:** after import, re-assign assets to AssetBundles and rebuild for Android.
The ripped project has the source assets (`Texture2D/`, `Scenes/`, `Resources/`),
so this is a rebuild, not a re-author. Expect texture re-compression (DXT → ETC2/ASTC)
and shader variant gaps.

## B4 — Lua not yet extracted

`StreamingAssets/lua/luascripts` is a UnityFS bundle (1.13 MB). Gameplay logic lives
inside as TextAssets. Must be unpacked before any logic can be audited or patched.

## B5 — Input

The build is keyboard/mouse (ships `keybord.png`, `Gamepad(Xbox One).png`,
`Default_Input.jpg`). Android needs touch: on-screen stick + buttons, or gamepad mapping.
Expect to hook the input layer (cf. the MKM port's `UnifiedInputHandler` approach).

## B6 — Paths / save data

Unity 5.4 PC builds commonly write saves relative to the executable. Android requires
`Application.persistentDataPath`. Grep for `Application.dataPath`, `UserData`, and
relative file writes before first device test.

## B7 — Play Store distribution is not viable

Even if built: base APK ~200 MB cap, install-time asset packs ~4 GB cap. An ~8 GB
game cannot ship on Play without on-demand asset packs. Sideloading an APK is fine.

---

## Suggested order

```
B1 toolchain  ->  B4 lua extract (cheap, do in parallel)  ->  B2 native .so
   ->  B3 bundle rebuild  ->  B6 paths  ->  B5 input  ->  device test
```

B1 and B2 are the two that can kill the project outright. Validate them first,
before investing in B3.
