import 'package:flutter/material.dart';

class CampoTextoCustomizado extends StatefulWidget {
  final String label;
  final String? dica;
  final bool esSenha;
  final TextEditingController? controller;
  final String? Function(String?)? validador;
  final Function(String)? aoMudar;
  final IconData? icone;
  final int linhasMaximas;

  const CampoTextoCustomizado({
    super.key,
    required this.label,
    this.dica,
    this.esSenha = false,
    this.controller,
    this.validador,
    this.aoMudar,
    this.icone,
    this.linhasMaximas = 1,
  });

  @override
  State<CampoTextoCustomizado> createState() => CampoTextoCustomizadoState();
}

class CampoTextoCustomizadoState extends State<CampoTextoCustomizado> {
  late bool exibirSenha;

  @override
  void initState() {
    super.initState();
    exibirSenha = !widget.esSenha;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.esSenha && !exibirSenha,
      maxLines: widget.esSenha && !exibirSenha ? 1 : widget.linhasMaximas,
      validator: widget.validador,
      onChanged: widget.aoMudar,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.dica,
        prefixIcon: widget.icone != null ? Icon(widget.icone) : null,
        suffixIcon: widget.esSenha
            ? IconButton(
                icon: Icon(
                  exibirSenha ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    exibirSenha = !exibirSenha;
                  });
                },
              )
            : null,
      ),
    );
  }
}
