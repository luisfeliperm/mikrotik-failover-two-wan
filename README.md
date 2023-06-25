Create 06/2023 | @author luisfeliperm
# Script Failover - RouterOS
##### \#mikrotik, #HealthCheck, #failover, #twoWans, #routeros, #script
#### Funcionamento
O funcionamento do script é baseado no comentário das rotas e nome da interface principal. 
Para o funcionamento, deve-se ter criado as rotas estaticas ou dinamicas para o Gateway. 
Comentar **"gwPrimary"** e **"gwBackup"** nas respectivas rotas.

    [luisfrm@RB_Casa] > ip route  print
	 #      DST-ADDRESS      PREF-SRC     GATEWAY         DISTANCE
	 0 AS  ;;; gwPrimary
             0.0.0.0/0                    pppoe-out1      10
	 1  S   ;;; gwBackup
            0.0.0.0/0                     pppoe-out2      11


As variaveis **\$primaryInterface** e **\$gwPrimary** são diretamente ligadas, ou seja, a rota  **gwPrimary**  deve apontar para **primaryInterface**


#### Variaveis personalizaveis
|Variavel|Descrição|
|:-|:-|
|**primaryInterface**|Nome da interface principal, ex: pppoe-out1, ether1|
|**gwPrimary**|Comentário da rota do link principal|
|**gwBackup**|Comentário da rota do link backup|
|**icmpCount**|Quantidade de pacotes ICMP a ser enviado|
|**retry**|Numero de tentativas caso falhe o teste de ping|
|**target1**|Alvo para teste de ping ex: 8.8.8.8|
|**target2**|Segundo alvo para teste de ping ex: 1.1.1.1|




### Após adicionar o script, execute o comando:
```bash
/system scheduler add name="Failover Script" interval=30 on-event="/system script run failover" start-time=startup
```

Deve-se ficar atento ao "interval" do Scheduler para não rodar multiplos scripts simultaneamente

Faça os calculos *****{icmpCount \* retry \* 2 (Targets) }*****, acrescente mais uns 5 segundos

 Exemplo:
`icmpCount = `4
`retry = 3`
`Target = 2 (Padrão do script)`

***4 * 3 * 2 + 5  = 29 segundos***


### *This is it, thanks!!*


