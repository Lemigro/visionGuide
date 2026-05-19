"""Instâncias compartilhadas (injeção de dependência simples)."""

from repositories.repositorio_autenticacao import RepositorioAutenticacao
from services.autenticacao_servico import AutenticacaoServico
from services.chat_servico import ChatServico
from services.visao_servico import VisaoServico

repositorio_autenticacao = RepositorioAutenticacao()
autenticacao_servico = AutenticacaoServico(repositorio_autenticacao)
chat_servico = ChatServico()
visao_servico = VisaoServico()
