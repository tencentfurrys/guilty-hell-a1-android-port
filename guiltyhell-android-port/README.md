# Guilty Hell A1 — Android port feasibility experiment

Private save point. **Contains no game assets** — only analysis, measurements and tooling.

Source archive: `GuiltyHell_A1_-_Copy.7z` (local only, never committed).

---

## Target

| Property | Value |
|---|---|
| Build | Guilty Hell A1 |
| Unity | **5.4.6f3** (2016) |
| Scripting | **Mono** (`Assembly-CSharp.dll`), no `global-metadata.dat` |
| Extra scripting | **slua** (Lua via native plugin) |
| Native plugins | `slua.dll`, `EffekseerUnity.dll` — Windows PE x64 |
| Archive | 5,734,313,036 B compressed → 8,873,225,131 B (8.26 GiB) |
| Files | 1171 files / 53 folders, solid archive, 239 blocks |

---

## Where the size actually is

| Area | Size | Notes |
|---|---|---|
| AssetBundles (`StreamingAssets/bundles`, no ext) | 4.43 GiB | compress 1.12x → already compressed |
| `.resS` streams | 2.46 GiB | compress **5.07x** → raw PCM audio / uncompressed textures |
| `GunslingerCostumePatch.exe` | 1.06 GiB | redundant installer |
| everything else | ~0.3 GiB | |

### Compression ratio is the diagnostic

- `1.12x` on bundles = payload is entropy-dense = already BC/DXT + Ogg/LZ4. **No safe gain.**
- `5.07x` on `.resS` = raw PCM. **~1.9 GiB of theoretical gain**, but only via Unity asset repacking.

---

## Results so far

| Step | Size | Status |
|---|---|---|
| Baseline extracted | 8.26 GiB | ✅ measured |
| Base game only (no `additional_contents`, no patch exe) | **3.46 GiB** | ✅ extracted, 868 files, verified |
| − `.resS` PCM → Vorbis | ~1.95 GiB est. | ⬜ not attempted (needs UABEA) |

Base extraction verified present: `A1.exe`, `A1_Data/Managed` (25 DLLs), `Plugins/slua.dll`,
`resources.assets`, `globalgamemanagers` (5.4.6f3).

---

## Route evaluation

| Route | Verdict |
|---|---|
| **Winlator** (Wine + Box64) | ✅ Play on Android now. Docs list `Stability (Unity Games)` preset + `-force-gfx-direct`. |
| **AssetRipper → Unity project → APK** (mkm methodology) | ⚠️ Architecturally correct, months of work. See `docs/03`. |
| Custom VM runner (`wolfvm` style) | ❌ Category error — Unity is a full engine, not a bytecode VM. |
| REA (`morluto/rea`) | ❌ Analysis only. No repacker, no Android export. Its Unity support is IL2CPP-only; this build is Mono. |

---

## Known blockers for a real APK

1. **No Unity project.** Only build output exists.
2. **DXT/BC textures inside 4.4 GiB of prebuilt bundles** — Adreno/Mali need ETC2/ASTC.
   Rebuilding every bundle for ETC2 is the hard part.
3. **Native plugins have no ARM64 `.so`.** `slua` and `Effekseer` are open source, so rebuilds
   are possible, but must link against a Unity 5.4 project that doesn't exist yet.
4. **Unity 5.4.6f3 toolchain** — ancient Android Build Support + NDK r10e/r11.
5. **AssetRipper 2.0 free build cannot export a Unity project** — see `docs/03`.

---

## Next steps

- [ ] Resolve Unity-project export path (AssetRipper Premium, or build CLI from source)
- [ ] Test whether AssetRipper reconstructs scenes coherently on 5.4.6f3
- [ ] Audit texture formats inside bundles (`AssetStudio` / `UnityPy`) to size the ETC2 work
- [ ] Decide: Winlator (days) vs full port (months)

---

## Legal

Game assets are the property of their developers. This repo is a private interoperability
backup of *methodology and measurements* only.
