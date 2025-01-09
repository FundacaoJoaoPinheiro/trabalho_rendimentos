#!/bin/sh

# Shell script para importar os microdados da PNAD Contínua Anual, 1a visita
# de 2023. Pode ser executado na maioria dos sistemas baseados em Unix (Linux,
# macOS, BSD) que tenham curl e unzip instalados.

# Você também pode usar os links para fazer os downloads manualmente
# pelo seu navegador. Extraia os arquivos em uma pasta chamada "Microdados"
# para que os dados possam ser corretamente acessados (ou altere o caminho
# no script principal).

# Entre no link abaixo para navegar no servidor do IBGE:
# https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/

mkdir -p Microdados
cd Microdados

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_1/Dados/PNADC_2023_visita1_20241220.zip
unzip PNADC_2023_visita1_20241220.zip
rm PNADC_2023_visita1_20241220.zip

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_1/Documentacao/dicionario_PNADC_microdados_2023_visita1_20241220.xls

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Visita_1/Documentacao/input_PNADC_2023_visita1_20241220.txt

curl -O https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/Visita/Documentacao_Geral/deflator_PNADC_2023.xls
