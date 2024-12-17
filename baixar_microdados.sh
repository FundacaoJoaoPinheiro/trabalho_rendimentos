#!/bin/sh

# Shell script para importar os microdados da PNAD Contínua Anual, 5a visita.
# Pode ser executado na maioria dos sistemas baseados em Unix (Linux, macOS,
# BSD) que tenham curl e unzip instalados.

# O ano da visita é definido pela variável $ANO. Também pode ser definido
# na linha de comando:
# $ baixar_microdados.sh 2023

# Você também pode usar os links para fazer os downloads manualmente
# pelo seu navegador. Extraia os arquivos em uma pasta chamada "Microdados"
# para que os dados possam ser corretamente acessados (ou altere o caminho
# no script principal).

ANO=${1:-2023}

mkdir -p Microdados
cd Microdados

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_5/Dados/PNADC_"$ANO"_visita5.zip
unzip PNADC_"$ANO"_visita5.zip
rm PNADC_"$ANO"_visita5.zip

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_5/Documentacao/dicionario_PNADC_microdados_"$ANO"_visita5.xls

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_5/Documentacao/input_PNADC_"$ANO"_visita5.txt

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Documentacao_Geral/deflator_PNADC_"$ANO".xls
