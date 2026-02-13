# PC Data

***English information down below.***

<img width="812" height="794" alt="Captura_de_tela-07" src="https://github.com/user-attachments/assets/78ebaa86-bfae-4692-84df-283641fd37a9" />

# Planos:

- Implementar informações de RAM, GPU, placa mãe, BIOS e etc;
- Tradução para português;
- Desenvolver uma GUI (interface gráfica) em Qt ou GTK.

Script simples para mostrar informações do hardware no Linux.

## Dependências:

Esse script foi testado no Debian 13. Todos os pacotes utilizados por este script vieram pré-instalados no Debian.
Os pacotes necessários para usar esse script são (nomes baseados nos repositórios do Debian):

- util-linux;
- dmidecode;
- lm-sensors;
- grep, sed, awk and coreutils (probably installed by default on any distro).

## Como usar:

1. Salve o script em qualquer pasta no seu PC;
2. Dê permissão de execução via "propriedades" no gerenciador de arquivos com o comando `chmod +x pcdata.sh`;
3. Abra o terminal, navegue até a pasta onde o script se encontra e execute-o com `./pcdata.sh`.

## Informações extras:

Alguns comandos, como o `dmidecode` exigem autenticação com `sudo` para funcionar. Por isso o script irá solicitar a sua senha de usuário ao ser executádo.

## ENGLISH

## To Do:

- Implement RAM, GPU, Motherboard, and BIOS information;
- Translation to portuguese;
- Develop a GUI (Graphical User Interface) using Qt or GTK.

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
3. Open the terminal, navigate to the folder where the script is located, and run it with `./pcdata.sh`.

## Extra information:

Some commands, such as `dmidecode`, require `sudo` authentication to function correctly. Therefore, the script will prompt for your user password when executed.
