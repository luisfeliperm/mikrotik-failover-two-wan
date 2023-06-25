################################################
####
####  Create 06/2023
####  @author luisfeliperm
#### 
####  github.com/luisfeliperm
####  Documentation: https://github.com/luisfeliperm/mikrotik-failover-two-wan
####
####  Comment language: pt-br
####
################################################


# :log info "[ScriptFailOver] Iniciando"

# "primaryInterface", nome da interface principal, ex: pppoe-out1, ether1...
:local primaryInterface "ppp-prismarede"
# "principal" Comentário da rota do link principal
:local gwPrimary "gwPrimary"
# "gwBackup" Comentário da rota do link backup
:local gwBackup    "gwBackup"
# "icmpCount" Quantidade de pacotes ICMP a ser enviado.
:local icmpCount 4
# "retry" Numero de tentativas caso falhe o teste de ping
:local retry 3
# "target1", alvo para teste de ping
:local target1 "8.8.8.8"
# "target2", Segundo alvo para teste de ping
:local target2 "8.8.4.4"

:local sucessPing true
:local gwCurrent

# Function troca Link
:global AlterWan do={
	/ip route set [find comment=$1] distance=10
	/ip route set [find comment=$2] distance=11
    :log warning "[ScriptFailOver.AlterWan] Ativo: $1 | Backup: $2"
    /ip firewall connection remove [find]
}
{
	# Pega o link atual
	:local tmpPrimary [/ip route get [find comment=$gwPrimary] distance]
	:local tmpBackup [/ip route get [find comment=$gwBackup] distance]

	:if ($tmpPrimary < $tmpBackup) do={
		# :log info "[ScriptFailOver.GetActiveLink] $gwPrimary é o atual"
		:set gwCurrent $gwPrimary
	} else={
		# :log info "[ScriptFailOver.GetActiveLink] $gwBackup é o atual"
		:set gwCurrent $gwBackup
	}
}

:local totalAcceptPing 0
:local x 1
:do {
	# :log info "[ScriptFailOver.Ping.Retry.$x] Iniciando retry $x"

	:set totalAcceptPing [/ping count=$icmpCount interface=$primaryInterface $target1]

	if ($totalAcceptPing>0) do={
		# :log info "[ScriptFailOver.Retry$x.Target1] Link $primaryInterface OK. ($totalAcceptPing/$icmpCount)"
		:set $retry 0
		
	} else={
		# :log info "[ScriptFailOver.Retry$x] Falha no Target1, iniciando Target2"

		:set totalAcceptPing [/ping count=$icmpCount interface=$primaryInterface $target2]
		if ($totalAcceptPing>0) do={
			# Sucesso no segundo teste
			# :log info "[ScriptFailOver.Retry$x.Target1] Link $primaryInterface OK. ($totalAcceptPing/$icmpCount)"
			:set $retry 0
		} else={
			# Falhou o segundo teste
			# :log info "[ScriptFailOver.Ping.Retry.$x] Falhou nos dois target"
			if ($retry = $x) do={
				# :log info "[ScriptFailOver.Ping.Retry.$x] Tentativas esgotadas"
				:set sucessPing false
			}
			:set x ($x + 1)
		}
	}
} while=($x <= $retry);

:if ($sucessPing = true) do={
	# :log info "[ScriptFailOver] Link $primaryInterface OK"

	:if ($gwCurrent != $gwPrimary) do={
		:log warning "[ScriptFailOver] Definindo Link $primaryInterface como ativo "
		$AlterWan gwPrimary  gwBackup
	}
} else={ 

	:if ($gwCurrent != $gwBackup) do={
		:log warning "[ScriptFailOver] Definindo Link backup como principal "
		$AlterWan gwBackup gwPrimary
	}
}