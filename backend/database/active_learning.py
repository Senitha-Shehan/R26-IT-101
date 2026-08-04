import os
import sys
import json
import uuid
from datetime import datetime, timezone

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

# Ensure backend root directory is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from database.mongodb import get_uncertain_collection

LOCAL_QUEUE_FILE = os.path.join("data", "pending_uncertain_samples.json")

def _safe_print(msg):
    """Safely prints message handling Windows encoding limitations."""
    try:
        print(msg)
    except UnicodeEncodeError:
        ascii_msg = msg.replace("✓", "[OK]").replace("⚠", "[WARNING]")
        print(ascii_msg)


def _load_local_queue():
    """Loads all samples from the local JSON queue file."""
    if not os.path.exists(LOCAL_QUEUE_FILE):
        return []
    try:
        with open(LOCAL_QUEUE_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        _safe_print(f"Warning: Could not read local queue file ({e}). Starting fresh.")
        return []


def _save_local_queue(queue):
    """Saves the given queue list to the local JSON queue file."""
    os.makedirs(os.path.dirname(LOCAL_QUEUE_FILE), exist_ok=True)
    with open(LOCAL_QUEUE_FILE, "w", encoding="utf-8") as f:
        json.dump(queue, f, indent=2, default=str)


def sync_pending_samples():
    """
    Attempts to sync all pending unsynced samples from local storage to MongoDB Atlas.
    Returns a tuple: (synced_count, last_inserted_id)
    """
    queue = _load_local_queue()
    unsynced = [s for s in queue if not s.get("synced", False)]

    if not unsynced:
        return 0, None

    collection = get_uncertain_collection()
    if collection is None:
        # Connection unavailable / offline
        return 0, None

    synced_in_batch = 0
    last_inserted_id = None

    for sample in queue:
        if not sample.get("synced", False):
            try:
                created_at_val = sample.get("created_at")
                if isinstance(created_at_val, str):
                    try:
                        created_at_dt = datetime.fromisoformat(created_at_val)
                    except Exception:
                        created_at_dt = datetime.now(timezone.utc)
                else:
                    created_at_dt = datetime.now(timezone.utc)

                mongo_doc = {
                    "image_path": sample["image_path"],
                    "predicted_disease": sample["predicted_disease"],
                    "confidence": sample["confidence"],
                    "threshold": sample["threshold"],
                    "region": sample["region"],
                    "model_name": sample["model_name"],
                    "created_at": created_at_dt,
                    "status": sample.get("status", "pending"),
                    "expert_label": sample.get("expert_label", None)
                }

                result = collection.insert_one(mongo_doc)
                sample["synced"] = True
                sample["mongo_id"] = str(result.inserted_id)
                last_inserted_id = result.inserted_id
                synced_in_batch += 1
            except Exception as e:
                _safe_print(f"Sync error for sample {sample.get('local_id')}: {e}")
                break  # Stop batch on network interruption

    if synced_in_batch > 0:
        _save_local_queue(queue)

    return synced_in_batch, last_inserted_id


def save_uncertain_sample(
    image_path,
    predicted_disease,
    confidence,
    threshold,
    region,
    model_name
):
    """
    Saves an uncertain sample locally first, then attempts to sync to MongoDB Atlas.
    If offline, keeps the sample stored locally as pending for later synchronization.
    """
    local_id = uuid.uuid4().hex[:12]
    created_at_iso = datetime.now(timezone.utc).isoformat()

    sample_record = {
        "local_id": local_id,
        "image_path": image_path,
        "predicted_disease": predicted_disease,
        "confidence": float(confidence),
        "threshold": float(threshold),
        "region": region,
        "model_name": model_name,
        "created_at": created_at_iso,
        "status": "pending",
        "expert_label": None,
        "synced": False
    }

    # 1. Save sample locally first (Guarantees offline reliability)
    queue = _load_local_queue()
    queue.append(sample_record)
    _save_local_queue(queue)

    _safe_print(f"\nSaved sample locally to pending queue (Local ID: {local_id})")

    # 2. Try to sync with MongoDB Atlas
    synced_count, last_id = sync_pending_samples()

    if synced_count > 0:
        _safe_print(f"✓ Synced to MongoDB Atlas! (Record ID: {last_id})")
        if synced_count > 1:
            _safe_print(f"  (Synced a total of {synced_count} pending samples)")
    else:
        _safe_print("⚠ Connection unavailable: Saved locally for later synchronization.")

    return local_id


if __name__ == "__main__":
    _safe_print("Checking pending samples for MongoDB synchronization...")
    synced_count, _ = sync_pending_samples()
    _safe_print(f"Sync complete. Total samples uploaded to MongoDB: {synced_count}")