import os

import cv2
from ultralytics import YOLO

_yolo_model = None
_face_cascade = None


def configurar_diretorios_ultralytics() -> None:
    current_dir = os.getcwd()
    config_dir = os.path.join(current_dir, ".ultralytics", "config")
    settings_dir = os.path.join(current_dir, ".ultralytics", "settings")

    os.environ["ULTRALYTICS_CONFIG_DIR"] = config_dir
    os.environ["ULTRALYTICS_SETTINGS_DIR"] = settings_dir
    os.environ["YOLO_CONFIG_DIR"] = config_dir

    os.makedirs(config_dir, exist_ok=True)
    os.makedirs(settings_dir, exist_ok=True)


def carregar_modelos_visao() -> None:
    global _yolo_model, _face_cascade

    configurar_diretorios_ultralytics()

    try:
        _yolo_model = YOLO("yolov8n.pt")
        print("YOLOv8 carregado com sucesso!")
    except Exception as exc:
        print(f"Erro ao carregar YOLOv8: {exc}")
        _yolo_model = None

    try:
        _face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
        )
        print("Detector de rostos carregado com sucesso!")
    except Exception as exc:
        print(f"Erro ao carregar detector de rostos: {exc}")
        _face_cascade = None


def obter_modelo_yolo():
    return _yolo_model


def obter_detector_rostos():
    return _face_cascade
