from datetime import datetime, timedelta

from fastapi import HTTPException, status

from repositories.repositorio_autenticacao import RepositorioAutenticacao
from schemas.autenticacao import (
    DadosLogin,
    DadosOtp,
    DadosRegistro,
    RespostaLogin,
    RespostaOtp,
    VerificacaoOtp,
)


class AutenticacaoServico:
    def __init__(self, repositorio: RepositorioAutenticacao | None = None) -> None:
        self._repo = repositorio or RepositorioAutenticacao()

    @property
    def repositorio(self) -> RepositorioAutenticacao:
        return self._repo

    def inicializar(self) -> None:
        self._repo.garantir_usuario_teste()

    @staticmethod
    def _gerar_token(usuario_id: int) -> str:
        return f"token_jwt_{usuario_id}_{datetime.now().timestamp()}"

    @staticmethod
    def _usuario_resposta(usuario: dict) -> dict:
        return {
            "id": str(usuario["id"]),
            "email": usuario["email"],
            "nome": usuario["nome"],
        }

    def registrar(self, dados: DadosRegistro) -> RespostaLogin:
        if self._repo.email_cadastrado(dados.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="E-mail já cadastrado",
            )

        otp = self._repo.buscar_otp(dados.email)
        if not otp:
            return RespostaLogin(
                status=False,
                mensagem="Nenhum OTP enviado para este e-mail",
            )

        if self._repo.otp_expirado(dados.email):
            self._repo.remover_otp(dados.email)
            return RespostaLogin(status=False, mensagem="Código OTP expirado")

        if dados.codigoOtp != otp["codigo"]:
            return RespostaLogin(status=False, mensagem="Código OTP inválido")

        usuario = self._repo.criar_usuario(
            dados.email,
            dados.nome,
            self._repo.hash_senha(dados.senha),
        )
        self._repo.remover_otp(dados.email)

        return RespostaLogin(
            status=True,
            mensagem="Usuário registrado com sucesso",
            token=self._gerar_token(usuario["id"]),
            usuario=self._usuario_resposta(usuario),
        )

    def login(self, dados: DadosLogin) -> RespostaLogin:
        if self._repo.verificar_bloqueio(dados.email):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    f"Muitas tentativas. Bloqueado por "
                    f"{self._repo.TEMPO_BLOQUEIO_MINUTOS} minutos"
                ),
            )

        usuario = self._repo.buscar_usuario(dados.email)
        if not usuario or usuario["senha"] != self._repo.hash_senha(dados.senha):
            self._repo.registrar_tentativa_falha(dados.email)
            return RespostaLogin(
                status=False,
                mensagem="E-mail ou senha incorretos",
            )

        self._repo.limpar_tentativas(dados.email)
        return RespostaLogin(
            status=True,
            mensagem="Login realizado com sucesso",
            token=self._gerar_token(usuario["id"]),
            usuario=self._usuario_resposta(usuario),
        )

    def enviar_otp(self, dados: DadosOtp) -> RespostaOtp:
        codigo = self._repo.gerar_codigo_otp()
        expira_em = datetime.now() + timedelta(minutes=2.17)
        self._repo.salvar_otp(dados.email, codigo, expira_em)
        print(f"[SIMULAÇÃO] OTP para {dados.email}: {codigo}")
        return RespostaOtp(
            status=True,
            mensagem="Código OTP enviado com sucesso",
            expira_em=expira_em.isoformat(),
        )

    def verificar_otp(self, dados: VerificacaoOtp) -> dict:
        otp = self._repo.buscar_otp(dados.email)
        if not otp:
            return {"status": False, "mensagem": "Nenhum OTP enviado para este e-mail"}

        if self._repo.otp_expirado(dados.email):
            self._repo.remover_otp(dados.email)
            return {"status": False, "mensagem": "Código OTP expirado"}

        if dados.codigo != otp["codigo"]:
            return {"status": False, "mensagem": "Código OTP inválido"}

        return {"status": True, "mensagem": "Código OTP verificado com sucesso"}
