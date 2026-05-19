import hashlib
import os
import random
import string
from datetime import datetime, timedelta


class RepositorioAutenticacao:
    """Persistência em memória (substituível por banco de dados depois)."""

    MAX_TENTATIVAS_LOGIN = 5
    TEMPO_BLOQUEIO_MINUTOS = 15

    def __init__(self) -> None:
        self._usuarios: dict[str, dict] = {}
        self._otps: dict[str, dict] = {}
        self._tentativas_login: dict[str, dict] = {}

    @staticmethod
    def hash_senha(senha: str) -> str:
        return hashlib.sha256(senha.encode("utf-8")).hexdigest()

    @staticmethod
    def gerar_codigo_otp(comprimento: int = 6) -> str:
        return "".join(random.choices(string.digits, k=comprimento))

    def garantir_usuario_teste(self) -> None:
        if os.getenv("DESABILITAR_USUARIO_TESTE", "").lower() in ("1", "true", "sim"):
            return

        email = os.getenv("USUARIO_TESTE_EMAIL", "teste@visionguide.com")
        senha = os.getenv("USUARIO_TESTE_SENHA", "123456")
        nome = os.getenv("USUARIO_TESTE_NOME", "Usuário Teste")

        self._usuarios[email] = {
            "id": 1,
            "email": email,
            "nome": nome,
            "senha": self.hash_senha(senha),
            "criado_em": datetime.now().isoformat(),
        }
        print(f"[DEV] Usuário de teste: {email} / {senha}")

    def email_cadastrado(self, email: str) -> bool:
        return email in self._usuarios

    def buscar_usuario(self, email: str) -> dict | None:
        return self._usuarios.get(email)

    def criar_usuario(self, email: str, nome: str, senha_hash: str) -> dict:
        usuario = {
            "id": len(self._usuarios) + 1,
            "email": email,
            "nome": nome,
            "senha": senha_hash,
            "dataCadastro": datetime.now().isoformat(),
        }
        self._usuarios[email] = usuario
        return usuario

    def salvar_otp(self, email: str, codigo: str, expira_em: datetime) -> None:
        self._otps[email] = {"codigo": codigo, "expira_em": expira_em}

    def buscar_otp(self, email: str) -> dict | None:
        return self._otps.get(email)

    def remover_otp(self, email: str) -> None:
        self._otps.pop(email, None)

    def otp_expirado(self, email: str) -> bool:
        otp = self.buscar_otp(email)
        if not otp:
            return True
        return datetime.now() > otp["expira_em"]

    def verificar_bloqueio(self, email: str) -> bool:
        if email not in self._tentativas_login:
            return False

        info = self._tentativas_login[email]
        bloqueado_ate = info.get("bloqueado_ate")

        if bloqueado_ate and datetime.now() < bloqueado_ate:
            return True

        if bloqueado_ate and datetime.now() >= bloqueado_ate:
            self._tentativas_login[email] = {"tentativas": 0, "bloqueado_ate": None}
            return False

        return False

    def registrar_tentativa_falha(self, email: str) -> None:
        if email not in self._tentativas_login:
            self._tentativas_login[email] = {"tentativas": 0, "bloqueado_ate": None}

        self._tentativas_login[email]["tentativas"] += 1

        if self._tentativas_login[email]["tentativas"] >= self.MAX_TENTATIVAS_LOGIN:
            self._tentativas_login[email]["bloqueado_ate"] = datetime.now() + timedelta(
                minutes=self.TEMPO_BLOQUEIO_MINUTOS
            )

    def limpar_tentativas(self, email: str) -> None:
        if email in self._tentativas_login:
            self._tentativas_login[email] = {"tentativas": 0, "bloqueado_ate": None}
