from fastapi import APIRouter

from dependencies import autenticacao_servico
from schemas.autenticacao import (
    DadosLogin,
    DadosOtp,
    DadosRegistro,
    RespostaLogin,
    RespostaOtp,
    VerificacaoOtp,
)

router = APIRouter()


@router.post("/registrar", response_model=RespostaLogin)
async def registrar_usuario(dados: DadosRegistro):
    return autenticacao_servico.registrar(dados)


@router.post("/login", response_model=RespostaLogin)
async def fazer_login(dados: DadosLogin):
    return autenticacao_servico.login(dados)


@router.post("/enviar-otp", response_model=RespostaOtp)
async def enviar_otp(dados: DadosOtp):
    return autenticacao_servico.enviar_otp(dados)


@router.post("/verificar-otp")
async def verificar_otp(dados: VerificacaoOtp):
    return autenticacao_servico.verificar_otp(dados)
