import io
import os
import sys
import uuid
import unittest
from PIL import Image
from fastapi.testclient import TestClient

# Ensure backend root is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.main import app
from database.mongodb import get_uncertain_collection

# Ensure UTF-8 output on Windows
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

client = TestClient(app)


class TestCropGuardAPI(unittest.TestCase):
    def setUp(self):
        self.img = Image.new("RGB", (100, 100), color="green")
        self.img_bytes = io.BytesIO()
        self.img.save(self.img_bytes, format="JPEG")
        self.img_bytes.seek(0)

    def test_01_health_endpoint(self):
        """Test GET /api/health endpoint"""
        response = client.get("/api/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok"})
        print("[OK] Health endpoint returned 200 OK")

    def test_02_uncertain_sample_upload_and_duplicate_protection(self):
        """Test POST /api/uncertain-samples with upload and duplicate protection"""
        sample_id = f"test_{uuid.uuid4().hex[:10]}"
        self.img_bytes.seek(0)
        files = {
            "image": ("test_leaf.jpg", self.img_bytes, "image/jpeg")
        }
        data = {
            "sample_id": sample_id,
            "predicted_disease": "Leaf Blast",
            "confidence": 0.64,
            "region": "uva_zone",
            "model_id": "uva_zone_float16.tflite",
            "timestamp": "2026-08-12T22:50:00Z"
        }

        # 1. Initial upload
        response = client.post("/api/uncertain-samples", files=files, data=data)
        self.assertIn(response.status_code, [200, 201])
        res_data = response.json()
        self.assertEqual(res_data["sample_id"], sample_id)
        self.assertEqual(res_data["predicted_disease"], "Leaf Blast")
        self.assertAlmostEqual(res_data["confidence"], 0.64, places=2)
        self.assertEqual(res_data["status"], "pending_review")
        self.assertEqual(res_data["is_duplicate"], False)
        print(f"[OK] Upload succeeded for sample_id: {sample_id}")

        # Check server filesystem
        expected_filepath = os.path.join(PROJECT_ROOT, "uploaded_samples", f"{sample_id}.jpg")
        self.assertTrue(os.path.exists(expected_filepath), f"File not found at {expected_filepath}")
        print(f"[OK] File saved on disk at {expected_filepath}")

        # Check MongoDB storage if connected
        collection = get_uncertain_collection()
        if collection is not None:
            doc = collection.find_one({"sample_id": sample_id})
            self.assertIsNotNone(doc)
            self.assertEqual(doc["status"], "pending_review")
            print(f"[OK] Document verified in MongoDB Atlas for sample_id: {sample_id}")

        # 2. Duplicate upload retry with same sample_id
        self.img_bytes.seek(0)
        dup_files = {
            "image": ("test_leaf.jpg", self.img_bytes, "image/jpeg")
        }
        dup_response = client.post("/api/uncertain-samples", files=dup_files, data=data)
        self.assertEqual(dup_response.status_code, 200)
        dup_res_data = dup_response.json()
        self.assertEqual(dup_res_data["sample_id"], sample_id)
        self.assertTrue(dup_res_data["is_duplicate"])
        print(f"[OK] Duplicate upload correctly handled idempotently for sample_id: {sample_id}")



if __name__ == "__main__":
    unittest.main()
