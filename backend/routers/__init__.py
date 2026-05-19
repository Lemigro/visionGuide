from .autenticacao import router as router_autenticacao
from .chat import router as router_chat
from .saude import router as router_saude
from .visao import router as router_visao

__all__ = [
    "router_autenticacao",
    "router_visao",
    "router_chat",
    "router_saude",
]
