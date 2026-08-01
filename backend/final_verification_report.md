# CropGuard AutoML Regional Model Final Verification Report

This report lists the results of running inference verification on the finalized, optimized regional AutoML models. For each active class in each region, 3 sample images were selected, preprocessed, and classified by the corresponding AutoML model to verify correct functionality and lack of corruption.

## Executive Summary

| Region | Active Classes Count | Images Tested | Correct Predictions | Inference Accuracy | Average Confidence | Overall Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Central Highlands** | 2 | 6 | 6 | 100.00% | 88.00% | **✅ PASS** |
| **Uva Zone** | 2 | 6 | 6 | 100.00% | 95.62% | **✅ PASS** |
| **Eastern Dry Zone** | 4 | 12 | 10 | 83.33% | 84.69% | **✅ PASS** |
| **North Central Dry Zone** | 3 | 9 | 9 | 100.00% | 89.23% | **✅ PASS** |
| **Northern Dry Zone** | 2 | 6 | 5 | 83.33% | 94.60% | **✅ PASS** |
| **Northwestern Intermediate** | 2 | 6 | 6 | 100.00% | 96.35% | **✅ PASS** |
| **Sabaragamuwa Zone** | 2 | 6 | 6 | 100.00% | 81.51% | **✅ PASS** |
| **Southern Wet Zone** | 3 | 9 | 9 | 100.00% | 93.32% | **✅ PASS** |
| **Western Wet Zone** | 3 | 9 | 9 | 100.00% | 97.57% | **✅ PASS** |

## Detailed Prediction Records

### Region: `central_highlands` (Central Highlands)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 94.65% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 82.07% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 84.09% | ✅ PASS |
| `Leaf_blast  (1).jpg` | Leaf Blast | Leaf Blast | 87.52% | ✅ PASS |
| `Leaf_blast  (10).jpg` | Leaf Blast | Leaf Blast | 86.83% | ✅ PASS |
| `Leaf_blast  (100).jpg` | Leaf Blast | Leaf Blast | 92.84% | ✅ PASS |

### Region: `uva_zone` (Uva Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.74% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 96.62% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 95.41% | ✅ PASS |
| `Leaf_blast  (1).jpg` | Leaf Blast | Leaf Blast | 97.30% | ✅ PASS |
| `Leaf_blast  (10).jpg` | Leaf Blast | Leaf Blast | 87.51% | ✅ PASS |
| `Leaf_blast  (100).jpg` | Leaf Blast | Leaf Blast | 97.17% | ✅ PASS |

### Region: `eastern_dry_zone` (Eastern Dry Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Bacterial_leaf_Blight  (1).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 98.71% | ✅ PASS |
| `Bacterial_leaf_Blight  (10).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 48.85% | ✅ PASS |
| `Bacterial_leaf_Blight  (100).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 90.29% | ✅ PASS |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Rice Hispa | 74.78% | ❌ FAIL |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 98.73% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.20% | ✅ PASS |
| `Narrow_brown_leaf_spot  (1).jpg` | Narrow Brown Leaf Spot | Narrow Brown Leaf Spot | 83.74% | ✅ PASS |
| `Narrow_brown_leaf_spot  (10).jpg` | Narrow Brown Leaf Spot | Rice Hispa | 68.85% | ❌ FAIL |
| `Narrow_brown_leaf_spot  (100).jpg` | Narrow Brown Leaf Spot | Narrow Brown Leaf Spot | 95.54% | ✅ PASS |
| `Rice_hispa  (1).jpg` | Rice Hispa | Rice Hispa | 98.39% | ✅ PASS |
| `Rice_hispa  (10).jpg` | Rice Hispa | Rice Hispa | 60.34% | ✅ PASS |
| `Rice_hispa  (100).jpg` | Rice Hispa | Rice Hispa | 98.84% | ✅ PASS |

### Region: `north_central_dry_zone` (North Central Dry Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Bacterial_leaf_Blight  (1).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 98.68% | ✅ PASS |
| `Bacterial_leaf_Blight  (10).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 77.72% | ✅ PASS |
| `Bacterial_leaf_Blight  (100).jpg` | Bacterial Leaf Blight | Bacterial Leaf Blight | 96.16% | ✅ PASS |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.98% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.70% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.63% | ✅ PASS |
| `Narrow_brown_leaf_spot  (1).jpg` | Narrow Brown Leaf Spot | Narrow Brown Leaf Spot | 68.14% | ✅ PASS |
| `Narrow_brown_leaf_spot  (10).jpg` | Narrow Brown Leaf Spot | Narrow Brown Leaf Spot | 76.25% | ✅ PASS |
| `Narrow_brown_leaf_spot  (100).jpg` | Narrow Brown Leaf Spot | Narrow Brown Leaf Spot | 86.81% | ✅ PASS |

### Region: `northern_dry_zone` (Northern Dry Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Rice Hispa | 97.58% | ❌ FAIL |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 98.18% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 95.37% | ✅ PASS |
| `Rice_hispa  (1).jpg` | Rice Hispa | Rice Hispa | 99.57% | ✅ PASS |
| `Rice_hispa  (10).jpg` | Rice Hispa | Rice Hispa | 77.19% | ✅ PASS |
| `Rice_hispa  (100).jpg` | Rice Hispa | Rice Hispa | 99.68% | ✅ PASS |

### Region: `northwestern_intermediate` (Northwestern Intermediate)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.90% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 97.03% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 94.33% | ✅ PASS |
| `Leaf_scald  (1).jpg` | Leaf scald | Leaf scald | 87.79% | ✅ PASS |
| `Leaf_scald  (10).jpg` | Leaf scald | Leaf scald | 99.56% | ✅ PASS |
| `Leaf_scald  (100).jpg` | Leaf scald | Leaf scald | 99.50% | ✅ PASS |

### Region: `sabaragamuwa_zone` (Sabaragamuwa Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 98.64% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 90.12% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 59.55% | ✅ PASS |
| `Leaf_scald  (1).jpg` | Leaf scald | Leaf scald | 68.83% | ✅ PASS |
| `Leaf_scald  (10).jpg` | Leaf scald | Leaf scald | 89.00% | ✅ PASS |
| `Leaf_scald  (100).jpg` | Leaf scald | Leaf scald | 82.93% | ✅ PASS |

### Region: `southern_wet_zone` (Southern Wet Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Brown_spot  (1).jpg` | Brown Spot | Brown Spot | 94.59% | ✅ PASS |
| `Brown_spot  (10).jpg` | Brown Spot | Brown Spot | 98.59% | ✅ PASS |
| `Brown_spot  (100).jpg` | Brown Spot | Brown Spot | 99.81% | ✅ PASS |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.85% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 62.96% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 90.36% | ✅ PASS |
| `Sheath_blight  (1).jpg` | Sheath Blight | Sheath Blight | 97.66% | ✅ PASS |
| `Sheath_blight  (10).jpg` | Sheath Blight | Sheath Blight | 97.47% | ✅ PASS |
| `Sheath_blight  (100).jpg` | Sheath Blight | Sheath Blight | 98.61% | ✅ PASS |

### Region: `western_wet_zone` (Western Wet Zone)

| Image File | Actual Class | Predicted Class | Confidence | Status |
| :--- | :--- | :--- | :---: | :---: |
| `Brown_spot  (1).jpg` | Brown Spot | Brown Spot | 95.74% | ✅ PASS |
| `Brown_spot  (10).jpg` | Brown Spot | Brown Spot | 99.29% | ✅ PASS |
| `Brown_spot  (100).jpg` | Brown Spot | Brown Spot | 99.93% | ✅ PASS |
| `Healthy_rice_leaf  (1).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 99.88% | ✅ PASS |
| `Healthy_rice_leaf  (10).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 95.83% | ✅ PASS |
| `Healthy_rice_leaf  (100).jpg` | Healthy Rice Leaf | Healthy Rice Leaf | 96.59% | ✅ PASS |
| `Sheath_blight  (1).jpg` | Sheath Blight | Sheath Blight | 98.33% | ✅ PASS |
| `Sheath_blight  (10).jpg` | Sheath Blight | Sheath Blight | 95.12% | ✅ PASS |
| `Sheath_blight  (100).jpg` | Sheath Blight | Sheath Blight | 97.45% | ✅ PASS |
