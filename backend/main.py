import asyncio
import os
import sys
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.visao_modelos import carregar_modelos_visao
from dependencies import autenticacao_servico
from routers import (
    router_autenticacao,
    router_chat,
    router_saude,
    router_visao,
)

load_dotenv(override=True)


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Evita traceback ruidoso no Windows quando o cliente fecha o WebSocket."""
    if sys.platform == "win32":
        loop = asyncio.get_running_loop()

        def _tratar_excecao_loop(loop, context):
            exc = context.get("exception")
            if isinstance(exc, ConnectionResetError):
                return
            loop.default_exception_handler(context)

        loop.set_exception_handler(_tratar_excecao_loop)
    yield


carregar_modelos_visao()
autenticacao_servico.inicializar()

app = FastAPI(title="VisionGuide API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

app.include_router(router_saude, tags=["sistema"])
app.include_router(router_autenticacao, prefix="/auth", tags=["auth"])
app.include_router(router_visao, tags=["visao"])
app.include_router(router_chat, tags=["chat"])

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 3001))
    uvicorn.run(app, host="0.0.0.0", port=port)
