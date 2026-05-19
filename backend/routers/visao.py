from fastapi import APIRouter

from dependencies import visao_servico
from schemas.visao import RequisicaoImagem, RespostaAnalise

router = APIRouter()


@router.post("/analyze", response_model=RespostaAnalise)
async def analisar_imagem(requisicao: RequisicaoImagem):
    return visao_servico.analisar_imagem(requisicao.image)
