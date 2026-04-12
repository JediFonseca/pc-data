# PC Data

Script simples para mostrar informações do hardware no Linux.

***English information down below.***

<img width="739" height="557" alt="Captura_de_tela_20260412_143357" src="https://github.com/user-attachments/assets/92577e06-b153-4ee3-bf3a-d7b265d368e7" />

<img width="635" height="647" alt="Captura_de_tela_20260412_144024" src="https://github.com/user-attachments/assets/eae7f204-df7f-4d0a-917a-417ac03d05c3" />

<img width="610" height="690" alt="Captura_de_tela_20260412_144058" src="https://github.com/user-attachments/assets/423475dc-5eeb-49bd-b4fe-12d1fbab5443" />

# Planos:

- Implementar informações de GPU, placa mãe, BIOS e etc;
- Tradução para português;

## Dependências:

Esse script foi testado no Debian 13. Todos os pacotes utilizados por este script vieram pré-instalados no Debian.
Os pacotes necessários para usar esse script são (nomes baseados nos repositórios do Debian):

- util-linux;
- dmidecode;
- lm-sensors;
- grep, sed, awk and coreutils (provavelmente instalados por padrão em qualquer distro).

## Como usar:

1. Salve o script em qualquer pasta no seu PC;
2. Dê permissão de execução via "propriedades" no gerenciador de arquivos com o comando `chmod +x pcdata.sh`;
3. Abra o terminal, navegue até a pasta onde o script se encontra e execute-o com `./pcdata.sh`;
4. Para ajuda e informações avançadas utilize as flags "--help", "--ram" e "--cpu".

## Informações extras:

Alguns comandos, como o `dmidecode` exigem autenticação com `sudo` para funcionar. Por isso o script irá solicitar a sua senha de usuário ao ser executádo.

## ENGLISH

## To Do:

- Implement GPU, Motherboard, and BIOS information;
- Translation to portuguese;

## Dependencies:

Simple script for showing hardware information on Linux.

This script was tested on Debian 13. All the packages used by this script came preinstalled on Debian.
The packages needed to be able to use this script are (names based on the Debian repositories):
- util-linux;
- dmidecode;
- lm-sensors;
- grep, sed, awk and coreutils (probably installed by default on any distro).

## How to use it:

1. Save the script to any folder on your PC;
2. Grant execution permission via the file manager's "Properties" or by using the command `chmod +x pcdata.sh`;
3. Open the terminal, navigate to the folder where the script is located, and run it with `./pcdata.sh`;
4. For help and advanced usage use the flags "--help", "--ram" and "--cpu".

## Extra information:

Some commands, such as `dmidecode`, require `sudo` authentication to function correctly. Therefore, the script will prompt for your user password when executed.
