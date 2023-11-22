import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconeMapaOnibus extends StatelessWidget {
  final String nomeBusao;
  final double latitude;
  final double longitude;
  final String endereco;
  final int qtdPassageiros;
  final String valorPassagem;

  const IconeMapaOnibus({super.key, required this.nomeBusao, required this.latitude, required this.longitude, required this.endereco, required this.qtdPassageiros, required this.valorPassagem});

  @override
  Widget build(BuildContext context) {
    String mensagem1 = "Latitude: $latitude";
    String mensagem2 = "Longitude: $latitude";
    String mensagem3 = "Endereço: $endereco";
    String mensagem4 = "Quantidade de Passageiros: $qtdPassageiros";
    String mensagem5 = "Valor da Passagem: R\$ $valorPassagem";


    return InkWell(
      child: Column(
              children: [
                const FaIcon(FontAwesomeIcons.bus, color: Colors.red, size: 50), 
                Text(nomeBusao, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                context: context,
                                builder: (BuildContext bc) {
                                  return Wrap(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(mensagem1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.left,),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(mensagem2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.right,),
                                            )
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          child: Text(mensagem3),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          child: Text(mensagem4),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          child: Text(mensagem5),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
            },
    );
  }
}