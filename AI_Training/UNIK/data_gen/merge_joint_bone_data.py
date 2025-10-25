"""
UNIK Data Generator - Joint and Bone Data Merger
Merges joint and bone data for UNIK model training
"""

import os
import numpy as np
import logging
from typing import Set

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define datasets and data splits
SETS: Set[str] = {"train", "val"}
DATASETS: Set[str] = {"ntu/xview", "ntu/xsub"}


def merge_joint_bone_data() -> None:
    """
    Merge joint and bone data for UNIK training datasets
    """
    for dataset in DATASETS:
        for data_set in SETS:
            try:
                logger.info("Processing dataset: %s, set: %s", dataset, data_set)

                # Load joint and bone data
                joint_file = f"../data/{dataset}/{data_set}_data_joint.npy"
                bone_file = f"../data/{dataset}/{data_set}_data_bone.npy"

                # Check if files exist
                if not os.path.exists(joint_file):
                    logger.warning("Joint data file not found: %s", joint_file)
                    continue

                if not os.path.exists(bone_file):
                    logger.warning("Bone data file not found: %s", bone_file)
                    continue

                # Load data
                data_joint = np.load(joint_file)
                data_bone = np.load(bone_file)

                # Validate data shapes match
                if data_joint.shape != data_bone.shape:
                    logger.error(
                        "Shape mismatch for %s/%s: joint=%s, bone=%s",
                        dataset,
                        data_set,
                        data_joint.shape,
                        data_bone.shape,
                    )
                    continue

                # Get data dimensions
                N, C, T, V, M = data_joint.shape
                logger.info("Data shape: N=%d, C=%d, T=%d, V=%d, M=%d", N, C, T, V, M)

                # Merge joint and bone data along channel axis
                data_joint_bone = np.concatenate((data_joint, data_bone), axis=1)
                logger.info("Merged data shape: %s", data_joint_bone.shape)

                # Save merged data
                output_file = f"../data/{dataset}/{data_set}_data_joint_bone.npy"
                os.makedirs(os.path.dirname(output_file), exist_ok=True)
                np.save(output_file, data_joint_bone)

                logger.info("Successfully saved merged data to: %s", output_file)

            except (OSError, IOError) as e:
                logger.error(
                    "File I/O error processing %s/%s: %s", dataset, data_set, e
                )
                continue
            except ValueError as e:
                logger.error(
                    "Data processing error for %s/%s: %s", dataset, data_set, e
                )
                continue


if __name__ == "__main__":
    logger.info("Starting joint-bone data merging process")
    merge_joint_bone_data()
    logger.info("Data merging process completed")
