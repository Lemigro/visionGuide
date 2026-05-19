import base64

import cv2
import numpy as np
from fastapi import HTTPException

from core.visao_modelos import obter_detector_rostos, obter_modelo_yolo
from schemas.visao import RespostaAnalise

TRADUCOES_OBJETOS = {
    "person": "pessoa",
    "bicycle": "bicicleta",
    "car": "carro",
    "motorcycle": "moto",
    "bus": "ônibus",
    "truck": "caminhão",
    "traffic light": "semáforo",
    "stop sign": "placa de pare",
    "bench": "banco",
    "dog": "cachorro",
    "cat": "gato",
    "backpack": "mochila",
    "umbrella": "guarda-chuva",
    "handbag": "bolsa",
    "tie": "gravata",
    "suitcase": "mala",
    "bottle": "garrafa",
    "cup": "copo",
    "fork": "garfo",
    "knife": "faca",
    "spoon": "colher",
    "bowl": "tigela",
    "chair": "cadeira",
    "couch": "sofá",
    "potted plant": "planta",
    "bed": "cama",
    "dining table": "mesa de jantar",
    "toilet": "vaso sanitário",
    "tv": "televisão",
    "laptop": "laptop",
    "mouse": "mouse",
    "remote": "controle remoto",
    "keyboard": "teclado",
    "cell phone": "celular",
    "microwave": "micro-ondas",
    "oven": "forno",
    "sink": "pia",
    "refrigerator": "geladeira",
    "book": "livro",
    "clock": "relógio",
    "vase": "vaso",
    "scissors": "tesoura",
    "teddy bear": "urso de pelúcia",
    "hair drier": "secador de cabelo",
    "toothbrush": "escova de dentes",
}


class VisaoServico:
    def yolo_disponivel(self) -> bool:
        return obter_modelo_yolo() is not None

    def _detectar_yolo(self, imagem) -> list[dict]:
        modelo = obter_modelo_yolo()
        if modelo is None:
            return []

        resultados = modelo(imagem, verbose=False)
        deteccoes: list[dict] = []

        for resultado in resultados:
            for caixa in resultado.boxes:
                classe = int(caixa.cls[0])
                rotulo = modelo.names[classe]
                confianca = float(caixa.conf[0])
                if confianca > 0.4:
                    deteccoes.append({"label": rotulo, "confidence": confianca})

        return deteccoes

    def _decodificar_imagem(self, imagem_base64: str):
        _, codificado = (
            imagem_base64.split(",", 1) if "," in imagem_base64 else (None, imagem_base64)
        )
        bytes_imagem = base64.b64decode(codificado)
        array = np.frombuffer(bytes_imagem, np.uint8)
        imagem = cv2.imdecode(array, cv2.IMREAD_COLOR)

        if imagem is None:
            raise HTTPException(status_code=400, detail="Imagem inválida")

        return imagem

    def analisar_imagem(self, imagem_base64: str) -> RespostaAnalise:
        try:
            imagem = self._decodificar_imagem(imagem_base64)
            deteccoes_yolo = self._detectar_yolo(imagem)

            rostos_detectados = 0
            detector_rostos = obter_detector_rostos()
            if detector_rostos is not None:
                cinza = cv2.cvtColor(imagem, cv2.COLOR_BGR2GRAY)
                rostos = detector_rostos.detectMultiScale(cinza, 1.3, 5)
                rostos_detectados = len(rostos)

            resumo: list[str] = []
            for deteccao in deteccoes_yolo:
                rotulo_pt = TRADUCOES_OBJETOS.get(deteccao["label"], deteccao["label"])
                if rotulo_pt not in resumo:
                    resumo.append(rotulo_pt)

            if rostos_detectados > 0:
                texto_rosto = f"{rostos_detectados} rosto(s)"
                if texto_rosto not in resumo:
                    resumo.append(texto_rosto)

            if resumo:
                descricao = f"A imagem contém: {', '.join(resumo)}."
            else:
                descricao = "Nenhum objeto principal detectado na imagem."

            return RespostaAnalise(
                description=descricao,
                detections=deteccoes_yolo,
                summary=resumo,
            )
        except HTTPException:
            raise
        except Exception as exc:
            print(f"Erro ao analisar imagem: {exc}")
            raise HTTPException(status_code=500, detail=str(exc)) from exc
