from fastapi import APIRouter

from dependencies import chat_servico, visao_servico

router = APIRouter()


@router.get("/health")
async def health():
    return {
        "status": "ok",
        "provider": "python/fastapi",
        "yolo": visao_servico.yolo_disponivel(),
        "openai_chat": chat_servico.openai_habilitado(),
    }
