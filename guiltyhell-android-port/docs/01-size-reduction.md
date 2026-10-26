# 01 — Size reduction

## Tiers

| Tier | Action | Result | Risk |
|---|---|---|---|
| 0 | Drop `GunslingerCostumePatch.exe` | 7.20 GiB | none — content already in bundles |
| 1 | + drop `additional_contents/gun_costume` | 5.92 GiB | lose that costume |
| 2 | + drop all `additional_contents` | **3.46 GiB** | lose all optional content |
| 3 | + `.resS` PCM → Vorbis (UABEA) | ~1.95 GiB | repack, can break install |

Tier 2 was executed and verified — see `scripts/extract-base.ps1`.

## Why splitting into parts does not help

Splitting an archive or an APK reduces *per-download* size, never total size.
Five parts of 1.65 GiB is still 8.26 GiB. It only matters for media limits
(FAT32 4 GiB cap, USB sticks, Play Store per-artifact caps).

What *does* help is **not installing** optional content — which the game already supports,
because `additional_contents` is ~200 independently-loadable bundles.

## Restoring a single optional bundle

```powershell
& "C:\Program Files\7-Zip\7z.exe" x "GuiltyHell_A1_-_Copy.7z" `
  -o"<base>" -ir!*additional_contents\gun_costume* -y
```

That is the "individual parts" model, implemented at the filesystem level.

## The hard floor

After Tier 2 the remainder is:

- 1.85 GiB `A1_Data/resources` (`.resS` raw PCM + uncompressed texture data)
- ~1.4 GiB base bundles (sprites, cut-ins, sharedassets)
- ~0.2 GiB engine + managed code

Re-encoding audio gets you to ~2 GiB. Beyond that you are removing art, not compressing it.

## Reference point

`.kkrieger` is 97,280 bytes — a full 3D FPS. It is **not compressed**; it stores no assets at all.
Textures are stored as generation *history*, meshes as deformed primitives, audio synthesised at
load. It expands to ~300 MB in RAM.

That is the only route to orders-of-magnitude reduction, and it requires the source plus a rewrite.
It cannot be applied retroactively to an asset-heavy build.
