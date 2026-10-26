# 00 — Archive inventory

Measured with `7z l -slt`, parsed for `Path` / `Size` / `Packed Size` / `Folder`.

## Container

```
Solid = +        Blocks = 239
Files = 1171     Folders = 53
Size     = 8,873,225,131   (8.26 GiB)
Packed   = 5,734,313,036   (5.34 GiB)
Ratio    = 1.55x
```

## By extension

| Ext | Count | Size | Share |
|---|---|---|---|
| *(none)* — AssetBundles | 432 | 4.43 GiB | 53.6% |
| `.resS` | 91 | 2.46 GiB | 29.8% |
| `.exe` | 2 | 1.08 GiB | 13.0% |
| `.assets` | 112 | 0.12 GiB | 1.4% |
| `.resource` | 14 | 0.12 GiB | 1.4% |
| `.dll` | 28 | 0.02 GiB | 0.2% |
| misc | — | < 0.05 GiB | — |

## By compressibility

| Ext | Size | Packed | Ratio |
|---|---|---|---|
| bundle/noext | 4.01 GiB | 3.59 GiB | **1.12x** |
| `.resS` | 2.33 GiB | 0.46 GiB | **5.07x** |
| `.exe` | 1.08 GiB | 1.06 GiB | 1.01x |
| `.resource` | 0.12 GiB | 0.13 GiB | 0.89x |
| `.assets` | 0.09 GiB | 0.06 GiB | 1.45x |

Interpretation: bundles are already compressed (LZ4 + BC textures + Ogg). `.resS` is raw
PCM/uncompressed and is the only meaningful fat.

## Top single files

| Size | Path |
|---|---|
| 1.78 GiB | `A1_Data/resources.assets.resS` |
| 1.06 GiB | `GunslingerCostumePatch.exe` |
| 292 MiB | `bundles/magicGirl_t_sprites` |
| 227 MiB | `bundles/additional_contents/et40t` |
| 116 MiB | `A1_Data/resources.resource` |
| 110 MiB | `bundles/cut_in_images` |

## Optional content

`StreamingAssets/bundles/additional_contents` — **3.75 GiB across ~200 paired bundle sets**
(`et40` / `et40t`, `eacNN`, `gun_costume`, `magicanim`, `gunanim`, `bossmovie1`, `misc1`).

Largest: `gun_costume` at **1.28 GiB** (77 files).

## Duplicates

Only two same-size groups > 1 MB:

| Size | Copies |
|---|---|
| 11.10 MiB | `et31g` ×2 |
| 1.10 MiB | `level16`, `level22` |

Total dedupe opportunity ≈ 12 MiB. Not worth pursuing.
