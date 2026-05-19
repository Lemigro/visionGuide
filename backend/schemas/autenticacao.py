from pydantic import BaseModel


class DadosLogin(BaseModel):
    email: str
    senha: str


class DadosRegistro(BaseModel):
    email: str
    nome: str
    senha: str
    codigoOtp: str


class DadosOtp(BaseModel):
    email: str


class VerificacaoOtp(BaseModel):
    email: str
    codigo: str


class RespostaLogin(BaseModel):
    status: bool
    mensagem: str
    token: str | None = None
    usuario: dict | None = None


class RespostaOtp(BaseModel):
    status: bool
    mensagem: str
    expira_em: str | None = None
