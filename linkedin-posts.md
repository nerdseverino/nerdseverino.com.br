# Posts LinkedIn - Prontos para publicar

---

## 1. Comandos Linux SRE (reshare - teve só 3 impressões)

O alerta toca às 3h da manhã. Você entra no servidor. O que roda primeiro?

Depois de mais de uma década resolvendo incidentes em produção, esses são os comandos que rodo nos primeiros 60 segundos:

⚡ uptime → load average e tempo de pé
⚡ dmesg -T | tail -20 → kernel matou algo?
⚡ free -h → swap estourado = problema
⚡ df -h → disco cheio causa 30% dos incidentes
⚡ ss -tlnp → portas abertas e quem ouve

Se o load está alto, o dmesg mostra OOM kill e o swap está cheio — diagnóstico em 30 segundos.

O post completo tem seções sobre strace, /proc, iotop e one-liners que já me salvaram em produção.

E você, qual é o primeiro comando que roda quando entra num servidor com problema?

🔗 Link nos comentários

#Linux #SRE #DevOps #Troubleshooting #OnCall #Produção

---

## 2. Troubleshooting Docker (reshare - 25 impressões, 0 engajamento)

Container reiniciando em loop e você não sabe por quê?

O exit code te conta tudo:
🔴 137 → OOM killer matou (memória estourou)
🔴 139 → Segfault
🟡 1 → Erro da aplicação
🟢 0 → Saiu normal (mas não deveria)

Um comando que pouca gente conhece:

docker inspect <container> --format '{{.State.ExitCode}} - {{.State.OOMKilled}}'

Se OOMKilled = true, não adianta reiniciar — precisa aumentar o limite ou investigar memory leak.

Escrevi um guia completo com os comandos que uso para diagnosticar Docker em produção: disco cheio fantasma, rede, overlay2, health checks.

Qual o problema mais chato que você já teve com Docker em produção?

🔗 Link nos comentários

#Docker #DevOps #Containers #SRE #Troubleshooting #CloudNative

---

## 3. Memória Persistente Kiro (reshare - 13 impressões)

O maior problema de assistentes AI no terminal: cada sessão começa do zero.

Você explica o contexto, trabalha por 1 hora, fecha o terminal. Na próxima vez? Explica tudo de novo.

Resolvi com um sistema de memória em duas camadas:

🧠 Hot Memory → arquivo local com contexto dos últimos 7 dias
📦 Cold Memory → arquivo permanente no Obsidian para busca futura
📋 Runbook Pessoal → soluções de problemas que o Kiro lembra por mim

Agora quando abro o Kiro, ele já sabe:
→ Quais projetos estou tocando
→ Quais tarefas estão pendentes
→ Soluções de problemas anteriores

Assistente AI sem memória é como um colega brilhante com amnésia.

Você usa algum sistema para manter contexto entre sessões de AI?

🔗 Link nos comentários

#KiroCLI #AI #DevTools #Produtividade #SRE #Automação

---

## 4. Steering Files Kiro (reshare - 13 impressões)

Toda vez que abro o ChatGPT preciso explicar: "responda em português, seja técnico, não explique o óbvio".

No Kiro CLI resolvi isso com um arquivo de 20 linhas.

Steering files são regras permanentes que o Kiro segue em TODA sessão:

⚙️ Idioma e tom de resposta
⚙️ Ferramentas do meu ambiente (aws-vault, Docker, Zabbix)
⚙️ Regras de segurança (backup antes de modificar, nunca alterar permissões sem confirmar)
⚙️ Mapa de skills (qual skill ativar para cada tipo de problema)

A parte mais poderosa: lições aprendidas automáticas. Se eu corrijo o Kiro, ele atualiza o próprio steering para não repetir o erro.

O assistente literalmente aprende com as correções e persiste entre sessões.

Como você personaliza suas ferramentas de AI para o seu workflow?

🔗 Link nos comentários

#KiroCLI #AI #DevTools #Produtividade #EngenhariaDeSoftware #SRE
