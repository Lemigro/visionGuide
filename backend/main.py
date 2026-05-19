import os

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

carregar_modelos_visao()
autenticacao_servico.inicializar()

app = FastAPI(title="VisionGuide API")

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
