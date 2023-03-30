## vCenterPowerOff.ps1
Script para o desligamento de multiplas maquinas virtuais gerenciadas pelo vCenter de forma simplificada.

## Como utilizar
Antes de utilizar o script, é necessário instalar o modulo do VMware.PowerCLI no PowerShell. Para instalar o modulo necessário, basta utilizar o seguinte comando:

```
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
```

Após instalar o módulo, é necessário adicionar algumas informações ao codigo do script, são elas:
- Usuário do vCenter.
- Senha do vCenter.
- Endereço IP do servidor.
- Lista de hosts que serão desligados

As variáveis que receberão as credenciais de acesso e o endereço de servidor se encontram no início do código:

<p align="center">
 <img src=https://user-images.githubusercontent.com/85623265/209448773-9e5d5889-142d-4221-8930-83aa60b38433.png>
</p>

Os hosts que serão desligados deverão ser colocados no arquivo lista.txt. Todos os nomes dos hosts que estiverem neste arquivo serão desligados, cada host deve ser adicionado em uma linha, como no exemplo abaixo:

<p align="center">
 <img src=https://user-images.githubusercontent.com/85623265/209448700-fe58c5dd-d3d2-4de3-b7ba-1f5d4103e205.png>
</p>

## Como funciona
O script irá verificar o servidor vCenter e estabelecerá uma conexão a partir do IP e das credenciais fornecidas, com a conexão estabelecida, será enviado um sinal de desligamento para todos os hosts presentes no arquivo lista.txt. O script foi criado a partir da documentação fornecida pela vmware, mais informações em: https://developer.vmware.com/apis.
