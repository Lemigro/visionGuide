import json

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from dependencies import chat_servico, visao_servico

router = APIRouter()


def _extrair_imagem(message_data: dict) -> str | None:
    imagem = message_data.get("image") or message_data.get("imagem")
    if isinstance(imagem, str) and imagem.strip():
        return imagem.strip()
    return None


def _extrair_texto(message_data: dict) -> str:
    return (
        message_data.get("content")
        or message_data.get("message")
        or message_data.get("texto")
        or ""
    ).strip()


@router.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()
    historico: list[dict[str, str]] = []
    contexto_visual_sessao: str | None = None

    await websocket.send_json({
        "type": "message",
        "role": "assistant",
        "content": chat_servico.mensagem_boas_vindas(),
    })

    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)

            imagem = _extrair_imagem(message_data)
            user_message = _extrair_texto(message_data)

            if not imagem and not user_message:
                continue

            await websocket.send_json({
                "type": "typing",
                "role": "assistant",
                "content": True,
            })

            if imagem:
                try:
                    analise = visao_servico.analisar_imagem(imagem)
                    resumo_yolo = analise.description
                except Exception as exc:
                    print(f"Erro na análise YOLO: {exc}")
                    resumo_yolo = "Não foi possível detectar objetos automaticamente."

                legenda_usuario = user_message or "Descreva o que há nesta imagem."
                historico.append({
                    "role": "user",
                    "content": f"[Usuário enviou uma imagem] {legenda_usuario}",
                })

                descricao = await chat_servico.descrever_imagem(imagem, resumo_yolo)
                contexto_visual_sessao = (
                    f"{descricao} (Detecção automática: {resumo_yolo})"
                )
                historico.append({"role": "assistant", "content": descricao})

                await websocket.send_json({
                    "type": "message",
                    "role": "assistant",
                    "content": descricao,
                })
                continue

            resposta = await chat_servico.gerar_resposta(
                historico,
                user_message,
                contexto_visual=contexto_visual_sessao,
            )

            await websocket.send_json({
                "type": "message",
                "role": "assistant",
                "content": resposta,
            })

    except WebSocketDisconnect:
        print("Cliente desconectado do chat WebSocket")
    except Exception as exc:
        print(f"Erro no WebSocket chat: {exc}")
        try:
            await websocket.send_json({
                "type": "message",
                "role": "system",
                "content": "Conexão encerrada por erro no servidor. Tente reconectar.",
            })
            await websocket.close()
        except Exception:
            pass
