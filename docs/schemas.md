# Schemas — Dados do FutSim (MVP)


## adversarios.json
Lista de clubes por divisão. **Adversários não têm elenco** — apenas força por setor e nomes genéricos para eventos.


- `clubes`: array de clubes
- `id`: string única (kebab-case)
- `nome`: exibição
- `divisao`: "A" | "B" | "C" | "D"
- `setores`: { `ata`: number 1..10, `mei`: 1..10, `def`: 1..10, `gk`: 1..10 }
- `tendencia`: "esquerda" | "centro" | "direita"
- `nomes_padrao`: [string, string, string] — nomes para gols/eventos


## league_rules.json
Regras por divisão e calendário.
- `divisoes`: array
- `id`: "A"|"B"|"C"|"D"
- `nome`: string
- `clubes`: number (esperado por divisão, ex.: 20)
- `rodadas`: number (ex.: 38)
- `promove`: number
- `rebaixa`: number
- `calendario`: { `tipo`: "duplo_turno" }


## market_rules.json
Tabelas de preço/salário, prêmios e upgrades (valores seed, fáceis de tunar).
- `preco_por_ovr`: { "GK": [[ovrMin, ovrMax, preco]], "ZAG": [...], ... }
- `salario_por_ovr_idade`: [[ovrMin, idadeMin, salarioBase]]
- `premios_por_divisao`: { "A": { "vitoria": n, "empate": n, "derrota": n, "posicao_bonus": [pos->valor] }, ... }
- `custos_upgrades`: { "ofensivo": [[nivel, custo]], "defensivo": [...], "tecnico": [...], "fisico": [...], "mental": [...], "scout": [...], "diretor": [...], "ct": [...], "base": [[nivel, custo]] }
- `efeitos_staff`: { "scout_lista_por_nivel": [5,8,12,16,20,25,30,35,40,50], "diretor_desconto_pct": 2, "diretor_chance_pct": 3 }