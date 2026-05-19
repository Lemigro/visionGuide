/// Textos lidos em voz alta ao trocar de aba ou orientar o usuário.
class TextosAcessibilidade {
  TextosAcessibilidade._();

  static const anuncioAbaInicio =
      'Início. Descreva o ambiente ou fale com o assistente.';

  static const anuncioAbaDescrever =
      'Descrever o ambiente. Aponte o celular para frente e toque em '
      'capturar e descrever. O app tira a foto, analisa e fala em voz alta '
      'o que encontrou.';

  static const anuncioAbaAssistente =
      'Assistente. Use o microfone para perguntar em voz alta.';

  static const anuncioAbaAjustes =
      'Ajustes. Voz, texto ampliado e outras opções de acessibilidade.';

  static const anunciosAbas = <String>[
    anuncioAbaInicio,
    anuncioAbaDescrever,
    anuncioAbaAssistente,
    anuncioAbaAjustes,
  ];
}
