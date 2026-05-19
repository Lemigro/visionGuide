from pydantic import BaseModel


class RequisicaoImagem(BaseModel):
    image: str


class RespostaAnalise(BaseModel):
    description: str
    detections: list[dict]
    summary: list[str]
