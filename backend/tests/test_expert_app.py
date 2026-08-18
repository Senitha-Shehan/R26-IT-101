import os
import sys
import pytest
from datetime import datetime, timezone
from fastapi.testclient import TestClient

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.main import app
import api.routes.expert_reviews as expert_reviews_mod
from database.mongodb import get_uncertain_collection
from api.auth.security import EXPERT_DEFAULT_EMAIL, EXPERT_DEFAULT_PASSWORD

client = TestClient(app)

TEST_SAMPLE_ID = "test_sample_phase6_001"
TEST_IMAGE_FILENAME = f"{TEST_SAMPLE_ID}.jpg"
TEST_IMAGE_DIR = os.path.join(PROJECT_ROOT, "uploaded_samples")


class MockCollection:
    def __init__(self):
        self.docs = []

    def delete_many(self, query):
        if "sample_id" in query:
            self.docs = [d for d in self.docs if d.get("sample_id") != query["sample_id"]]
        return len(self.docs)

    def insert_one(self, doc):
        doc_copy = doc.copy()
        if "_id" not in doc_copy:
            from bson import ObjectId
            doc_copy["_id"] = ObjectId()
        self.docs.append(doc_copy)
        class Res:
            inserted_id = doc_copy["_id"]
        return Res()

    def find_one(self, query):
        if "$or" in query:
            for q in query["$or"]:
                res = self.find_one(q)
                if res: return res
            return None
        for d in self.docs:
            match = True
            for k, v in query.items():
                if k == "_id":
                    if str(d.get("_id")) != str(v):
                        match = False
                        break
                elif d.get(k) != v:
                    match = False
                    break
            if match:
                return d
        return None

    def count_documents(self, query):
        count = 0
        for d in self.docs:
            if not query or query == {}:
                count += 1
            elif "status" in query and isinstance(query["status"], dict) and "$in" in query["status"]:
                if d.get("status") in query["status"]["$in"]:
                    count += 1
        return count

    def find(self, query):
        results = []
        for d in self.docs:
            if not query or query == {}:
                results.append(d)
            elif "status" in query and isinstance(query["status"], dict) and "$in" in query["status"]:
                if d.get("status") in query["status"]["$in"]:
                    results.append(d)
        
        class Cursor:
            def __init__(self, data): self.data = data
            def sort(self, *args, **kwargs): return self
            def skip(self, *args, **kwargs): return self
            def limit(self, *args, **kwargs): return self
            def __iter__(self): return iter(self.data)
        return Cursor(results)

    def update_one(self, filter_q, update_q):
        doc = self.find_one(filter_q)
        if not doc:
            class Res: modified_count = 0
            return Res()
        if "$set" in update_q:
            for k, v in update_q["$set"].items():
                doc[k] = v
        class Res: modified_count = 1
        return Res()


mock_db_store = MockCollection()


@pytest.fixture(scope="module", autouse=True)
def setup_test_environment(monkeypatch_module):
    """Setup test sample document in MongoDB / Mock DB and test image on filesystem."""
    os.makedirs(TEST_IMAGE_DIR, exist_ok=True)
    test_image_path = os.path.join(TEST_IMAGE_DIR, TEST_IMAGE_FILENAME)

    with open(test_image_path, "wb") as f:
        f.write(b"\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xFF\xDB\x00C\x00")

    # Check live mongo or fallback mock
    real_coll = get_uncertain_collection()
    if real_coll is None:
        expert_reviews_mod.get_uncertain_collection = lambda: mock_db_store
        active_coll = mock_db_store
    else:
        active_coll = real_coll

    active_coll.delete_many({"sample_id": TEST_SAMPLE_ID})
    test_doc = {
        "sample_id": TEST_SAMPLE_ID,
        "image_path": f"uploaded_samples/{TEST_IMAGE_FILENAME}",
        "predicted_disease": "Rice Hispa",
        "confidence": 0.6149,
        "region": "central_highlands",
        "model_id": "central_highlands_float16.tflite",
        "status": "pending_review",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "uploaded_at": datetime.now(timezone.utc).isoformat(),
        "expert_label": None,
    }
    active_coll.insert_one(test_doc)

    yield

    try:
        active_coll.delete_many({"sample_id": TEST_SAMPLE_ID})
    except Exception:
        pass
    if os.path.exists(test_image_path):
        try:
            os.remove(test_image_path)
        except Exception:
            pass


@pytest.fixture(scope="module")
def monkeypatch_module():
    from _pytest.monkeypatch import MonkeyPatch
    mpatch = MonkeyPatch()
    yield mpatch
    mpatch.undo()


def get_authenticated_token():
    response = client.post(
        "/api/auth/login",
        json={"email": EXPERT_DEFAULT_EMAIL, "password": EXPERT_DEFAULT_PASSWORD},
    )
    assert response.status_code == 200
    data = response.json()
    return data["access_token"]


# ---------------------------------------------------------
# Test Cases 1-20
# ---------------------------------------------------------

def test_1_expert_login_success():
    """1. Expert login success"""
    res = client.post(
        "/api/auth/login",
        json={"email": EXPERT_DEFAULT_EMAIL, "password": EXPERT_DEFAULT_PASSWORD},
    )
    assert res.status_code == 200
    body = res.json()
    assert "access_token" in body
    assert body["user"]["email"] == EXPERT_DEFAULT_EMAIL.lower()


def test_2_invalid_login_rejected():
    """2. Invalid login rejected"""
    res = client.post(
        "/api/auth/login",
        json={"email": EXPERT_DEFAULT_EMAIL, "password": "wrongpassword123"},
    )
    assert res.status_code == 401
    assert "Invalid" in res.json()["detail"]


def test_3_unauthenticated_dashboard_request_rejected():
    """3. Unauthenticated dashboard request rejected"""
    res = client.get("/api/expert/dashboard-stats")
    assert res.status_code == 401


def test_4_authenticated_dashboard_request_succeeds():
    """4. Authenticated dashboard request succeeds"""
    token = get_authenticated_token()
    res = client.get(
        "/api/expert/dashboard-stats",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 200
    data = res.json()
    assert "pending_review" in data
    assert "reviewed" in data
    assert "total" in data


def test_5_pending_samples_retrieved():
    """5. Pending samples retrieved"""
    token = get_authenticated_token()
    res = client.get(
        "/api/expert/pending-samples?page=1&limit=10",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 200
    data = res.json()
    assert "items" in data
    assert isinstance(data["items"], list)


def test_6_sample_detail_retrieved():
    """6. Sample detail retrieved"""
    token = get_authenticated_token()
    res = client.get(
        f"/api/uncertain-samples/{TEST_SAMPLE_ID}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["sample_id"] == TEST_SAMPLE_ID
    assert data["predicted_disease"] == "Rice Hispa"


def test_7_authenticated_image_retrieval_succeeds():
    """7. Authenticated image retrieval succeeds"""
    token = get_authenticated_token()
    res = client.get(
        f"/api/uncertain-samples/{TEST_SAMPLE_ID}/image",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 200
    assert res.headers["content-type"].startswith("image/")


def test_8_unauthenticated_image_retrieval_rejected():
    """8. Unauthenticated image retrieval rejected"""
    res = client.get(f"/api/uncertain-samples/{TEST_SAMPLE_ID}/image")
    assert res.status_code == 401


def test_9_to_17_valid_expert_label_submission_and_mongo_update():
    """
    9. Valid expert label submission succeeds
    10. MongoDB document updated correctly
    11. AI prediction remains unchanged
    12. Confidence remains unchanged
    13. Expert label is stored
    14. Expert notes are stored
    15. Status changes to reviewed
    16. reviewed_at is generated server-side
    17. reviewer identity comes from authentication
    """
    token = get_authenticated_token()
    payload = {
        "sample_id": TEST_SAMPLE_ID,
        "expert_label": "Bacterial Leaf Blight",
        "expert_notes": "Symptoms consistent with bacterial blight lesions.",
    }
    res = client.post(
        "/api/expert/reviews",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 200
    body = res.json()
    assert "sample" in body
    sample = body["sample"]

    # Assert ground truth preservation & expert updates
    assert sample["predicted_disease"] == "Rice Hispa"  # 11. AI prediction unchanged
    assert float(sample["confidence"]) == 0.6149  # 12. Confidence unchanged
    assert sample["expert_label"] == "Bacterial Leaf Blight"  # 13. Expert label stored
    assert sample["expert_notes"] == "Symptoms consistent with bacterial blight lesions."  # 14. Notes stored
    assert sample["status"] == "reviewed"  # 15. Status changed to reviewed
    assert "reviewed_at" in sample and sample["reviewed_at"] is not None  # 16. Server timestamp
    assert sample["reviewed_by"] == EXPERT_DEFAULT_EMAIL.lower()  # 17. Authenticated reviewer identity


def test_18_already_reviewed_sample_cannot_be_overwritten():
    """18. Already-reviewed sample cannot be silently overwritten"""
    token = get_authenticated_token()
    payload = {
        "sample_id": TEST_SAMPLE_ID,
        "expert_label": "Brown Spot",
        "expert_notes": "Trying to overwrite",
    }
    res = client.post(
        "/api/expert/reviews",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code == 409  # Conflict
    assert "already been reviewed" in res.json()["detail"]


def test_19_invalid_disease_label_rejected():
    """19. Invalid disease label rejected"""
    token = get_authenticated_token()
    payload = {
        "sample_id": TEST_SAMPLE_ID,
        "expert_label": "Fake Invalid Disease Name 123",
        "expert_notes": "Invalid class test",
    }
    res = client.post(
        "/api/expert/reviews",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res.status_code in [422, 400]


def test_20_path_traversal_attempt_rejected():
    """20. Path traversal attempt rejected"""
    token = get_authenticated_token()

    coll = expert_reviews_mod.get_uncertain_collection()
    traversal_sample_id = "traversal_test_001"
    if coll is not None:
        coll.delete_many({"sample_id": traversal_sample_id})
        coll.insert_one({
            "sample_id": traversal_sample_id,
            "image_path": "../../../Windows/System32/drivers/etc/hosts",
            "predicted_disease": "Leaf Blast",
            "confidence": 0.5,
            "region": "central_highlands",
            "model_id": "test.tflite",
            "status": "pending_review",
            "created_at": datetime.now(timezone.utc).isoformat(),
        })

        res = client.get(
            f"/api/uncertain-samples/{traversal_sample_id}/image",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert res.status_code in [403, 404]
        coll.delete_many({"sample_id": traversal_sample_id})
