#ip vcenter
$vCenter = "IP do servidor"
#cRedenciais
$usuario = "Usuario"
$senha	 = "Senha"
#localizacao da lista de hosts
$diretorio = Get-Location
#maquinas a serem desligadas
$maquinas = Get-Content -Path $diretorio\lista.txt
#lista de VMS com erros no desligamento remoto
New-Object -TypeName System.Collections.ArrayList
$vmErrorList = [System.Collections.Arraylist]@()
$vmUnknowList = [System.Collections.Arraylist]@()

#sair do programa
function Sair {
	Read-Host -Prompt "Pressione enter para sair"
	exit
}

#testando conexão com VSphere
function Ping {
	echo "Verificando status da conexao com vCenter..."
	if (Test-Connection $vCenter -Count 3 -Delay 2 -Quiet) 
	{
		Write-Host "[+] vCenter ONLINE" -Foreground Green
	} else {
		Write-Host "[-] vCenter OFFLINE" -Foreground Red
		sleep 1
		echo "Nao foi possivel estabelecer uma conexao com o VSphere ($vCenter) verifique sua conexao"
		Sair
	}
}

#realizando login ao vcenter
function Conectar {
	echo "Realizando Login no ambiente vSphere..."
	if (Connect-VIServer -Server $vCenter -Protocol https -User $usuario -Password $senha -ErrorAction SilentlyContinue -Force)
	{
		Write-Host "[+] Login realizado com Sucesso" -Foreground Green
	} else {
		Write-Host "[-] Falha ao realizar o Login`n" -Foreground Red
		$Error[0]
		Sair
	}
}

#desligar equipamentos presentes na lista
function Desligar {
	echo "`nDesligando equipamentos, aguarde..."
	ForEach ($maquina in $maquinas)
	{
		if (Shutdow-VMGuest -VM $maquina -ErrorAction SilentlyContinue -Confirm:$false) {
			echo ("$maquina OK")
		} else {
			echo "$maquina ERRO"
			$vmErrorList.Add("$maquina") > $null
		}
	}
	sleep 10
}

#verifica o estado das vm
function VerificarStatus {
	echo "`nVerificando STATUS das maquinas virtuais."
	ForEach ($maquina in $maquinas) {
		$estadoVM = Get-VM $maquina -ErrorAction SilentlyContinue | select PowerState
		if ("$estadoVM" -eq "@{PowerState=PoweRedOn}")
		{
			$estadoVM = "[ONLINE]"
			$vmUnknowList.Add("$maquina") > $null
		} elseif ("$estadoVM" -eq "@{PowerState=PoweRedOff}") {
		$estadoVM = "[OFFLINE]"
		} else {
			$estadoVM = "[DESCONHECIDO]"
			$vmUnknowList.Add("$maquina") > $null
		}
		if ("$estadoVM" -eq "[ONLINE]") {
			Write-Host "$estadoVM $maquina" -Foreground Green
		}	elseif ("$estadoVM" -eq "[OFFLINE]") {
			Write-Host "$estadoVM $maquina" -Foreground Red
		} elseif ("$estadoVM" -eq "[DESCONHECIDO]") {
			Write-Host "$estadoVM $maquina" -Foreground Magenta
		}
	}
}

#função principal do script
function Main {
	echo "Script para o desligamento de maquinas virtuais gerenciadas pelo vCenter"
	Ping
	Conectar
	
	sleep 1
	echo "`nOs equipamentos da lista.txt serao desligados, Tem certeza do desligamento?"
	sleep 1
	$confirmacao = Read-Host -Prompt "Digite 'SIM' para prosseguir com a operacao."
	if ("$confirmacao" -eq "SIM") {
		Desligar
	} else {
		echo "encerrando o script."
		Sair
	}
	
	VerificarStatus

	#informacoes sobre desligamento
	if ($vmErrorList.Count -ne 0) {
		echo "`nMaquinas as quais nao foi possivel enviar o sinal de desligamento:"
		echo "$vmErrorList"
	}

	if ($vmUnknowList.Count -ne 0) {
		echo "`nMaquinas que não foram confirmadas como desligadas:"
		echo "$vmUnknowList"
	}
	
	if (($vmErrorList.Count -ne 0) -or ($vmUnknowList.Count -ne 0)) {
		echo "`nSERA NECESSARIO UMA INTERVENCAO MANUAL`n"
	}
	
	
	Echo "`SCRIPT Finalizado."

	Sair
}

Main
