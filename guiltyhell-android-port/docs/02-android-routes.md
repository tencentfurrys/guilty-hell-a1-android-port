# 02 — Android routes evaluated

## A. Winlator — run the Windows build on Android

Wine + Box86/Box64. Official docs call out Unity specifically:

- Box64 preset: **`Stability (Unity Games)`**
- exec argument: **`-force-gfx-direct`**
- fork `winebox64/winlator` mirrors the same advice

**Verdict: the only route that works today.** No port, no rebuild, no `.so`.
Constraint is phone storage — hence Tier 2 (3.46 GiB).

Repo: `brunodev85/winlator`

## B. AssetRipper → Unity project → APK

The `tencentfurrys/mkm-android-port` methodology (Mystic Knight Maya 0.7.5, Unity 2019.2.6f1, Mono):

1. AssetRipper 2.0 rips PC build → full Unity project
2. Hybrid decompile restores `Assembly-CSharp`
3. Android patches:
   - P0 save paths → `Application.persistentDataPath` (13 sites)
   - P1 JSON via embedded TextAssets / WebGL code path
   - P1d ripped TextAssets were trimmed WebGL copies — replaced with full data
   - P1g all 850 AudioClips `DecompressOnLoad` → `CompressedInMemory` (**RAM, not disk**)
   - P2 touch controls injected at `UnifiedInputHandler`
4. Headless build:
   ```
   Unity.exe -batchmode -quit -projectPath <repo>\unity-project `
     -executeMethod MKMBuild.BuildAndroid
   ```
5. Toolchain: Unity 2019.2.6f1 + Android module, SDK 28/29, build-tools 28.0.3,
   **NDK r16b** (hard requirement), bundled OpenJDK 8

**Verdict: correct architecture for a Unity Mono game.** Reuses Unity rather than reimplementing it.
Caveat: 0 stars / 0 forks / "private backup" — reference playbook, not maintained tooling.

## C. Custom VM runner (`wolfvm`)

Clean-room **Wolf RPG Editor 2.25** VM, C++17, Android target, dat-layer parsers + RE notes.

Wolf RPG Editor is a bytecode interpreter + 2D sprite player. Reimplementation is tractable
(same family as EasyRPG for RPG Maker 2000/2003).

**Verdict: wrong engine class.** Unity is not a VM you can reimplement — Mono IL is the smallest
part. You would also need a renderer, PhysX, Mecanim, FMOD, shader compiler and asset pipeline.

## D. REA (`morluto/rea`)

MCP server for reverse engineering: native binaries, IL2CPP metadata, Godot PCK, APK, .NET, WASM, etc.

**Verdict: not applicable.** No asset repacker, no Android export. Its Unity feature reads
**IL2CPP `global-metadata.dat`** — this build is Mono, so it does not apply at all.
Possible legitimate use: decompile `Assembly-CSharp.dll` to map bundle references.

## E. Sony/console pipeline

Oodle Kraken + hardware decompression, integrated at build time, licensed via RAD/Epic.
~30–40% better than the LZMA already used here. Cannot be applied to a finished binary.
Retail PS5 titles still ship 50–100 GB *with* Kraken.

## F. Unity split APKs / AAB / Play Asset Delivery

Real mechanism, correctly described:

- **Split APKs by target architecture** — one APK per ABI
- **AAB** — Play generates per-device config splits
- **Play Asset Delivery** — base module + asset packs, `install-time` / `fast-follow` / `on-demand`

Limits: ~200 MB base APK, ~4 GB install-time asset packs.

**Verdict: all are Editor build settings.** They cannot be produced from a finished Windows build.
And with one ABI and no localisations, the splitter returns a single APK — total size unchanged.
