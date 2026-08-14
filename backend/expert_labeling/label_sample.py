import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            ".."
        )
    )
)

from database.mongodb import get_uncertain_collection


CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]


def label_sample():
    uncertain_samples = get_uncertain_collection()
    if uncertain_samples is None:
        print(
            "\nError: Cannot connect to MongoDB. "
            "Please check your database connection and MONGODB_URI."
        )
        return

    sample_id = input(
        "\nEnter MongoDB Sample ID: "
    ).strip()

    from bson import ObjectId

    try:
        object_id = ObjectId(sample_id)
    except Exception:
        print("Invalid MongoDB Sample ID.")
        return

    query = {"status": {"$in": ["pending", "pending_review"]}}
    if object_id:
        query["$or"] = [{"_id": object_id}, {"sample_id": sample_id}]
    else:
        query["sample_id"] = sample_id

    sample = uncertain_samples.find_one(query)

    if not sample:

        print(
            "\nNo pending sample found "
            "with this ID."
        )

        return

    print("\n========================================")
    print("CROPGUARD EXPERT LABELING")
    print("========================================")

    print(
        f"\nImage Path:\n"
        f"{sample['image_path']}"
    )

    print(
        f"\nAI Prediction:\n"
        f"{sample['predicted_disease']}"
    )

    print(
        f"\nAI Confidence:\n"
        f"{sample['confidence']:.2%}"
    )

    print(
        f"\nRegion:\n"
        f"{sample.get('region', 'Unknown')}"
    )

    print("\nDisease Classes:")

    for index, disease in enumerate(
        CLASSES,
        start=1
    ):
        print(
            f"{index}. {disease}"
        )

    while True:

        choice = input(
            "\nEnter the correct disease number: "
        ).strip()

        try:
            choice = int(choice)

            if 1 <= choice <= len(CLASSES):
                break

        except ValueError:
            pass

        print(
            "Invalid choice. "
            "Please enter a number from 1 to 8."
        )

    expert_label = CLASSES[choice - 1]

    result = uncertain_samples.update_one(
        {"_id": sample["_id"]},
        {
            "$set": {
                "expert_label": expert_label,
                "status": "annotated"
            }
        }
    )

    if result.modified_count == 1:

        print("\n========================================")
        print("EXPERT LABEL SAVED SUCCESSFULLY")
        print("========================================")

        print(
            f"\nAI Prediction: "
            f"{sample['predicted_disease']}"
        )

        print(
            f"Expert Label: "
            f"{expert_label}"
        )

        print(
            "\nStatus: annotated"
        )

    else:

        print(
            "\nFailed to update sample."
        )


if __name__ == "__main__":
    label_sample()