import os
from typing import Any

from openai import AsyncOpenAI

PROMPT_ASSISTENTE_VISUAL = """Você é o VisionGuide, assistente visual para pessoas com deficiência visual ou baixa visão.

Regras obrigatórias:
- Você RECEBE e INTERPRETA imagens e leituras do ambiente enviadas pelo aplicativo.
- NUNCA diga que não consegue ver imagens, que não tem olhos ou que só pode ajudar se o usuário descrever.
- Use sempre o contexto visual fornecido (detecção de objetos, descrição da cena) para responder com segurança e clareza.
- Descreva ambientes, objetos, pessoas, animais, placas e possíveis obstáculos em português do Brasil.
- Oriente navegação quando fizer sentido (ex.: obstáculo à frente, caminho livre à direita).
- Frases curtas, adequadas para leitura em voz alta (TTS). Sem markdown.
- Seja empático e priorize a segurança do usuário."""

MENSAGEM_BOAS_VINDAS = (
    "Olá! Sou o assistente visual VisionGuide. "
    "Envie uma foto pela câmera ou pelo ícone de imagem no chat, e eu descrevo o ambiente para você. "
    "Também posso orientar na navegação e tirar dúvidas sobre o que foi analisado."
)

MAX_MENSAGENS_HISTORICO = 16

PROMPT_DESCRICAO_IMAGEM = (
    "Descreva esta imagem para uma pessoa com deficiência visual ou baixa visão. "
    "Inclua: o que aparece no centro e nas laterais, pessoas, animais, objetos, "
    "placas ou textos legíveis, obstáculos e sensação geral do ambiente (interno/externo, "
    "iluminação, movimento). Seja objetivo, em português do Brasil, em parágrafos curtos."
)


class ChatServico:
    def mensagem_boas_vindas(self) -> str:
        return MENSAGEM_BOAS_VINDAS

    def openai_habilitado(self) -> bool:
        provider = (os.getenv("AI_PROVIDER") or "").strip().lower()
        api_key = (os.getenv("OPENAI_API_KEY") or "").strip()
        if provider and provider != "openai":
            return False
        return bool(api_key)

    def _cliente_openai(self) -> AsyncOpenAI | None:
        if not self.openai_habilitado():
            return None
        return AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    def _modelo_chat(self) -> str:
        return os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    def _modelo_visao(self) -> str:
        return os.getenv("OPENAI_VISION_MODEL") or self._modelo_chat()

    @staticmethod
    def _normalizar_data_uri(imagem: str) -> str:
        imagem = imagem.strip()
        if imagem.startswith("data:"):
            return imagem
        return f"data:image/jpeg;base64,{imagem}"

    @staticmethod
    def resposta_fallback(conteudo: str, contexto_visual: str | None = None) -> str:
        if contexto_visual:
            return (
                f"Com base na última análise visual: {contexto_visual} "
                f"Sobre sua mensagem — {conteudo.strip()}"
            )

        texto = conteudo.lower()
        if texto in ("oi", "olá", "ola", "bom dia", "boa tarde", "boa noite"):
            return (
                "Olá! Envie uma foto pelo chat ou use a câmera assistiva "
                "para eu descrever o ambiente."
            )
        if "obrigad" in texto:
            return "Por nada! Estou à disposição quando precisar."

        return (
            "Para descrever fotos e ambientes com detalhes, configure OPENAI_API_KEY "
            "no .env do backend e reinicie o servidor. "
            "Enquanto isso, use a câmera assistiva: o app detecta objetos com visão computacional."
        )

    async def descrever_imagem(
        self,
        imagem_base64: str,
        resumo_deteccao: str,
    ) -> str:
        """Descrição rica da imagem (OpenAI Vision) com fallback YOLO."""
        data_uri = self._normalizar_data_uri(imagem_base64)
        cliente = self._cliente_openai()

        if cliente is not None:
            try:
                completion = await cliente.chat.completions.create(
                    model=self._modelo_visao(),
                    messages=[
                        {"role": "system", "content": PROMPT_ASSISTENTE_VISUAL},
                        {
                            "role": "user",
                            "content": [
                                {
                                    "type": "text",
                                    "text": (
                                        f"{PROMPT_DESCRICAO_IMAGEM}\n\n"
                                        f"Detecção automática auxiliar (YOLO): {resumo_deteccao}"
                                    ),
                                },
                                {
                                    "type": "image_url",
                                    "image_url": {"url": data_uri},
                                },
                            ],
                        },
                    ],
                    max_tokens=int(os.getenv("OPENAI_MAX_TOKENS", "550")),
                    temperature=0.5,
                )
                texto = completion.choices[0].message.content
                if texto and texto.strip():
                    return texto.strip()
            except Exception as exc:
                print(f"Erro OpenAI Vision: {exc}")

        return (
            f"Leitura do ambiente (visão computacional): {resumo_deteccao} "
            "Para descrições mais completas de animais, cenas e textos, "
            "configure OPENAI_API_KEY no backend."
        )

    async def gerar_resposta(
        self,
        historico: list[dict[str, str]],
        mensagem_usuario: str,
        contexto_visual: str | None = None,
    ) -> str:
        conteudo_usuario = mensagem_usuario.strip()
        if contexto_visual:
            conteudo_usuario = (
                f"[Última leitura visual do ambiente: {contexto_visual}]\n\n"
                f"Mensagem do usuário: {mensagem_usuario.strip()}"
            )

        historico.append({"role": "user", "content": conteudo_usuario})

        cliente = self._cliente_openai()
        if cliente is None:
            resposta = self.resposta_fallback(mensagem_usuario, contexto_visual)
            historico.append({"role": "assistant", "content": resposta})
            return resposta

        mensagens: list[dict[str, Any]] = [
            {"role": "system", "content": PROMPT_ASSISTENTE_VISUAL},
            *historico[-MAX_MENSAGENS_HISTORICO:],
        ]

        try:
            completion = await cliente.chat.completions.create(
                model=self._modelo_chat(),
                messages=mensagens,
                max_tokens=int(os.getenv("OPENAI_MAX_TOKENS", "450")),
                temperature=0.6,
            )
            resposta = (
                completion.choices[0].message.content
                or "Não consegui formular uma resposta agora. Tente novamente."
            ).strip()
        except Exception as exc:
            print(f"Erro OpenAI no chat: {exc}")
            resposta = (
                "Tive um problema ao consultar a IA. "
                "Verifique sua conexão e a chave da API, e tente de novo."
            )

        historico.append({"role": "assistant", "content": resposta})
        return resposta
