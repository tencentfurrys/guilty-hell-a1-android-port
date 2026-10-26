# 01 — Inventory & size analysis

All measurements from `7z l -slt` on the original archive, cross-checked after extraction.

## Compression reality

| Payload | Size | 7z ratio | Meaning |
|---|---|---|---|
| Unity AssetBundles (`StreamingAssets/bundles/*`, no extension) | **4.43 GiB** | **1.12x** | Already LZ4/BC-compressed inside. Nothing to gain. |
| `.resS` resource streams | **2.46 GiB** | **5.07x** | Raw PCM audio and/or uncompressed textures. Real air. |
| `GunslingerCostumePatch.exe` | **1.06 GiB** | 1.01x | Self-extracting installer; contents already in `additional_contents/gun_costume/`. |
| `.assets` / `.resource` / misc | ~0.3 GiB | — | |

**Conclusion:** the "uncompressed audio" theory is correct but narrow — only the
`.resS` streams are raw, and they are the *only* payload that compresses 5:1.
The 4.43 GiB of bundles are already dense and cannot be shrunk safely.

## Optional content (`StreamingAssets/bundles/additional_contents`)

**3.75 GiB across ~200 bundle pairs** (`etNN` + `etNNt`). Loaded on demand.
Largest single item: `gun_costume/` at **1.28 GiB** (77 files).

Deleting all of it is the single biggest safe win:

| Step | Result |
|---|---|
| Baseline extracted | 8.26 GiB |
| − patch installer | 7.20 GiB |
| − all `additional_contents` | **3.45 GiB** |
| − `.resS` PCM→Vorbis (UABEA) | ~1.95 GiB (theoretical floor) |

## Largest individual files

| File | Size |
|---|---|
| `A1_Data/resources.assets.resS` | 1.78 GB |
| `GunslingerCostumePatch.exe` | 1.13 GB |
| `bundles/magicGirl_t_sprites` | 306 MB |
| `additional_contents/et40t` | 238 MB |
| `A1_Data/resources.resource` | 122 MB |
| `bundles/cut_in_images` | 116 MB |

## Duplicates

Only ~12 MiB of byte-identical files (`et31g` x2, `level16`/`level22`).
Deduplication is not worth pursuing.

## Verified extraction command

```powershell
7z x "GuiltyHell_A1_-_Copy.7z" -o"GuiltyHell_Base" `
   "-xr!additional_contents" "-xr!GunslingerCostumePatch.exe" -y
# -> 868 files, 3.46 GiB, A1.exe + A1_Data + 25 managed DLLs intact
```

> Note: `-x!*pattern*` silently matches **nothing** here; use `-xr!name` form.
