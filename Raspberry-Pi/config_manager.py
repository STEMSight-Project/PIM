#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Configuration Manager
Handles loading and validation of configuration files
"""

import json
import os
import logging
from typing import Dict, Any


class ConfigManager:
    def __init__(self, config_dir: str = "config"):
        """
        Initialize configuration manager

        Args:
            config_dir: Directory containing configuration files
        """
        self.config_dir = config_dir
        self.camera_config = {}
        self.network_config = {}
        self.logger = self._setup_logging()

    def _setup_logging(self) -> logging.Logger:
        """Setup logging configuration"""
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            handlers=[logging.FileHandler("logs/config.log"), logging.StreamHandler()],
        )
        return logging.getLogger(__name__)

    def load_config(self, config_file: str) -> Dict[str, Any]:
        """
        Load configuration from JSON file

        Args:
            config_file: Name of configuration file

        Returns:
            Dictionary containing configuration
        """
        config_path = os.path.join(self.config_dir, config_file)

        if not os.path.exists(config_path):
            self.logger.error("Configuration file not found: %s", config_path)
            return {}

        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            self.logger.info("Loaded configuration from %s", config_file)
            return config
        except json.JSONDecodeError as e:
            self.logger.error("Invalid JSON in %s: %s", config_file, e)
            return {}
        except IOError as e:
            self.logger.error("Error loading %s: %s", config_file, e)
            return {}

    def load_camera_config(self) -> Dict[str, Any]:
        """Load camera configuration"""
        self.camera_config = self.load_config("camera_config.json")
        return self.camera_config

    def load_network_config(self) -> Dict[str, Any]:
        """Load network configuration"""
        self.network_config = self.load_config("network_config.json")
        return self.network_config

    def get_camera_setting(self, key: str, default: Any = None) -> Any:
        """
        Get camera configuration setting

        Args:
            key: Configuration key
            default: Default value if key not found

        Returns:
            Configuration value
        """
        return self.camera_config.get(key, default)

    def get_network_setting(self, key: str, default: Any = None) -> Any:
        """
        Get network configuration setting

        Args:
            key: Configuration key
            default: Default value if key not found

        Returns:
            Configuration value
        """
        return self.network_config.get(key, default)

    def validate_config(self) -> bool:
        """
        Validate loaded configuration

        Returns:
            True if configuration is valid
        """
        if not self.camera_config:
            self.logger.error("Camera configuration not loaded")
            return False

        if not self.network_config:
            self.logger.error("Network configuration not loaded")
            return False

        # Validate camera config
        required_camera_keys = ["resolution", "framerate"]
        for key in required_camera_keys:
            if key not in self.camera_config:
                self.logger.error("Missing required camera config: %s", key)
                return False

        # Validate network config
        required_network_keys = [
            "device_id",
            "server_url",
            "ambulance_number",
            "room_number",
        ]
        for key in required_network_keys:
            if key not in self.network_config:
                self.logger.error("Missing required network config: %s", key)
                return False

        self.logger.info("Configuration validation passed")
        return True

    def create_default_configs(self):
        """Create default configuration files if they don't exist"""
        os.makedirs(self.config_dir, exist_ok=True)

        # Default camera config
        camera_config_path = os.path.join(self.config_dir, "camera_config.json")
        if not os.path.exists(camera_config_path):
            default_camera = {
                "resolution": [1920, 1080],
                "framerate": 30,
                "exposure_mode": "auto",
                "white_balance": "auto",
                "rotation": 0,
                "preview_enabled": False,
            }
            with open(camera_config_path, "w", encoding="utf-8") as f:
                json.dump(default_camera, f, indent=2)
            self.logger.info("Created default camera configuration")

        # Default network config
        network_config_path = os.path.join(self.config_dir, "network_config.json")
        if not os.path.exists(network_config_path):
            default_network = {
                "device_id": "rpi-ambulance-001",
                "device_name": "Raspberry Pi Camera - Ambulance 001",
                "server_url": "http://localhost:8000",
                "ambulance_number": "001",
                "room_number": "001",
                "auto_start": True,
                "reconnect_interval": 5,
                "upload_interval": 30,
                "retry_attempts": 3,
                "timeout": 10,
                "heartbeat_interval": 30,
                "status_report_interval": 60,
            }
            with open(network_config_path, "w", encoding="utf-8") as f:
                json.dump(default_network, f, indent=2)
            self.logger.info("Created default network configuration")


if __name__ == "__main__":
    # Example usage
    config_manager = ConfigManager()
    config_manager.create_default_configs()

    camera_config = config_manager.load_camera_config()
    network_config = config_manager.load_network_config()

    if config_manager.validate_config():
        print("Configuration loaded successfully!")
        print(f"Device ID: {config_manager.get_network_setting('device_id')}")
        print(f"Resolution: {config_manager.get_camera_setting('resolution')}")
    else:
        print("Configuration validation failed!")
