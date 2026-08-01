import os
import csv
import shutil
from pathlib import Path

SOURCE_FOLDER = "raw_images"
TARGET_BASE = "data"
MAPPING_FILE = "disease_zone_mapping.csv"
REPORT_FILE = "dataset_report.md"

def load_mapping(mapping_csv_path):
    """Loads mapping from csv file. Returns (mapping_dict, all_diseases, all_zones)"""
    mapping = {} # disease -> list of zones
    all_diseases = set()
    all_zones = set()
    
    if not os.path.exists(mapping_csv_path):
        raise FileNotFoundError(f"Mapping file not found at {mapping_csv_path}")
        
    with open(mapping_csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            disease = row['Disease'].strip()
            zone = row['Zone'].strip()
            if not disease or not zone:
                continue
            all_diseases.add(disease)
            all_zones.add(zone)
            mapping.setdefault(disease, []).append(zone)
            
    return mapping, sorted(list(all_diseases)), sorted(list(all_zones))

def clean_and_setup_directories(target_base, all_zones, all_diseases):
    """Cleans up target base and creates fresh zone and disease directories."""
    print(f"Cleaning target directory: {target_base}...")
    if os.path.exists(target_base):
        for item in os.listdir(target_base):
            item_path = os.path.join(target_base, item)
            if os.path.isdir(item_path):
                shutil.rmtree(item_path)
            else:
                os.remove(item_path)
    else:
        os.makedirs(target_base, exist_ok=True)
        
    print("Setting up fresh folder structure...")
    for zone in all_zones:
        for disease in all_diseases:
            path = os.path.join(target_base, zone, disease)
            os.makedirs(path, exist_ok=True)

def generate_dataset():
    print("=== Regional Dataset Generation ===")
    
    # 1. Load mapping
    try:
        disease_to_zones, all_diseases, all_zones = load_mapping(MAPPING_FILE)
    except Exception as e:
        print(f"ERROR reading mapping: {e}")
        return
        
    print(f"Loaded mapping: {len(disease_to_zones)} diseases mapped across {len(all_zones)} zones.")
    
    # Verify source folder exists
    if not os.path.exists(SOURCE_FOLDER):
        print(f"ERROR: Source folder '{SOURCE_FOLDER}' not found!")
        return
        
    # 2. Clean and set up target directories
    clean_and_setup_directories(TARGET_BASE, all_zones, all_diseases)
    
    # 3. Process disease directories and copy images
    print("\nCopying images to respective agricultural zones...")
    
    # Track copy statistics
    copied_counts = {} # (zone, disease) -> count
    for zone in all_zones:
        for disease in all_diseases:
            copied_counts[(zone, disease)] = 0
            
    # List of common image extensions to look for
    image_extensions = ('*.jpg', '*.jpeg', '*.png', '*.JPG', '*.JPEG', '*.PNG')
    
    # Go through each disease folder in raw_images
    for disease_name in os.listdir(SOURCE_FOLDER):
        disease_path = os.path.join(SOURCE_FOLDER, disease_name)
        if not os.path.isdir(disease_path):
            continue
            
        if disease_name not in all_diseases:
            print(f"Warning: Disease folder '{disease_name}' in source folder not present in mapping.")
            continue
            
        # Get target zones for this disease
        target_zones = disease_to_zones.get(disease_name, [])
        if not target_zones:
            print(f"Warning: No target zones mapped for '{disease_name}'. Skipping copying.")
            continue
            
        # Collect all images in this disease folder
        images = []
        for ext in image_extensions:
            images.extend(Path(disease_path).glob(ext))
            
        print(f"Processing '{disease_name}': Found {len(images)} images. Mapped zones: {', '.join(target_zones)}")
        
        # Copy images to each mapped zone
        for zone in target_zones:
            target_dir = os.path.join(TARGET_BASE, zone, disease_name)
            for img_path in images:
                shutil.copy2(img_path, target_dir)
                copied_counts[(zone, disease_name)] += 1
                
    print("\nRegional dataset generation complete!")
    
    # 4. Generate Dataset Summary Report
    print("Generating report...")
    generate_report(all_zones, all_diseases, disease_to_zones, copied_counts)
    print(f"Report successfully saved to: {REPORT_FILE}")

def generate_report(all_zones, all_diseases, disease_to_zones, copied_counts):
    # Calculate stats
    zone_totals = {}
    disease_totals_global = {disease: 0 for disease in all_diseases}
    empty_folders_by_zone = {} # zone -> list of diseases
    missing_classes_by_zone = {} # zone -> list of diseases
    
    for zone in all_zones:
        zone_totals[zone] = 0
        empty_folders_by_zone[zone] = []
        missing_classes_by_zone[zone] = []
        
        for disease in all_diseases:
            count = copied_counts[(zone, disease)]
            zone_totals[zone] += count
            disease_totals_global[disease] += count
            
            # Check if empty folder
            if count == 0:
                empty_folders_by_zone[zone].append(disease)
                # Check if it was mapped (and thus should have had images)
                is_mapped = zone in disease_to_zones.get(disease, [])
                if is_mapped:
                    missing_classes_by_zone[zone].append(disease)

    # Build markdown report content
    lines = []
    lines.append("# Dataset Regionalization Report")
    lines.append("")
    lines.append("This report summarizes the generation of agricultural-zone-specific datasets from the original disease dataset.")
    lines.append("")
    
    lines.append("## Executive Summary")
    lines.append("")
    lines.append("| Agricultural Zone | Total Images | Mapped Classes Mapped | Empty Folders | Missing Classes (Mapped but 0 images) |")
    lines.append("| --- | --- | --- | --- | --- |")
    for zone in all_zones:
        num_mapped = sum(1 for d in all_diseases if zone in disease_to_zones.get(d, []))
        num_empty = len(empty_folders_by_zone[zone])
        num_missing = len(missing_classes_by_zone[zone])
        lines.append(f"| `{zone}` | {zone_totals[zone]} | {num_mapped} | {num_empty} | {num_missing} |")
    lines.append("")
    
    lines.append("## Global Disease Distribution (Post-Regionalization)")
    lines.append("")
    lines.append("| Disease Class | Total Regional Copies |")
    lines.append("| --- | --- |")
    for disease in all_diseases:
        lines.append(f"| `{disease}` | {disease_totals_global[disease]} |")
    lines.append("")
    
    lines.append("## Detailed Image Counts per Zone and Disease")
    lines.append("")
    
    # Header row for detailed table
    header = "| Disease Class | " + " | ".join([f"`{z}`" for z in all_zones]) + " |"
    divider = "| --- | " + " | ".join(["---" for _ in all_zones]) + " |"
    lines.append(header)
    lines.append(divider)
    
    for disease in all_diseases:
        row_str = f"| `{disease}` | "
        counts = []
        for zone in all_zones:
            count = copied_counts[(zone, disease)]
            is_mapped = zone in disease_to_zones.get(disease, [])
            if is_mapped:
                counts.append(f"**{count}**")
            else:
                counts.append(f"{count} (unmapped)")
        row_str += " | ".join(counts) + " |"
        lines.append(row_str)
    lines.append("")
    lines.append("> *Note: Bold numbers indicate the class is actively mapped to that zone.*")
    lines.append("")
    
    lines.append("## Missing Classes & Empty Folders Details")
    lines.append("")
    
    for zone in all_zones:
        lines.append(f"### Zone: `{zone}`")
        lines.append("")
        
        # Missing classes
        missing = missing_classes_by_zone[zone]
        if missing:
            lines.append(f"- ⚠️ **Missing Classes** (Mapped to this zone but 0 images generated):")
            for m in missing:
                lines.append(f"  - `{m}`")
        else:
            lines.append(f"- ✅ No missing classes (All mapped diseases have at least one image).")
            
        # Empty folders
        empty = empty_folders_by_zone[zone]
        if empty:
            lines.append(f"- 📁 **Empty Folders** (0 images, expected for unmapped classes):")
            # Distinguish between mapped empty and unmapped empty
            for e in empty:
                is_mapped = zone in disease_to_zones.get(e, [])
                status = "mapped, check source dataset" if is_mapped else "unmapped"
                lines.append(f"  - `{e}` ({status})")
        else:
            lines.append(f"- 📁 No empty folders.")
        lines.append("")
        
    # Write to report file
    with open(REPORT_FILE, mode='w', encoding='utf-8') as f:
        f.write("\n".join(lines))

if __name__ == "__main__":
    generate_dataset()
