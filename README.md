# Hyperliquid Funding Rate Arbitrage Bot

Bot delta-neutral que coleta funding rates na Hyperliquid automaticamente.

## Como funciona

```
Long Spot BTC  +  Short Perp BTC  =  Posição Delta-Neutral
     ↑                   ↑
  Sem risco de preço   Coleta funding a cada hora
```

Quando o mercado está bullish, traders pagam funding para manter posições long nos perps.
Você recebe esse pagamento sem risco direcional — qualquer alta no BTC é compensada pelo short perp.

## Pré-requisitos

- Python 3.10+
- Conta na Hyperliquid com USDC depositado
- Carteira Ethereum com chave privada (recomendado: carteira separada só para o bot)

## Instalação

```bash
# 1. Clonar / baixar os arquivos do bot
cd hl_funding_arb

# 2. Instalar dependências
pip install -r requirements.txt

# 3. Configurar
cp .env.example .env
# Abra .env com qualquer editor e preencha:
#   PRIVATE_KEY=0xSua_Chave_Privada
#   WALLET_ADDRESS=0xSeu_Endereço
#   TOTAL_CAPITAL_USDC=1000.0   (quanto alocar)
```

## Primeiros passos (LEIA ANTES DE RODAR)

### Passo 1 — Teste sem dinheiro real
```bash
python main.py --scan-only       # Ver funding rates agora
python main.py --dry-run         # Simular o bot sem executar ordens
```

### Passo 2 — Verificar saldo
```bash
python main.py --status          # Confirmar saldo e posições abertas
```

### Passo 3 — Rodar em produção
```bash
python main.py                   # Bot em modo real
```

## Estrutura do projeto

```
hl_funding_arb/
│
├── main.py                  # Ponto de entrada + CLI
├── config.py                # Configurações do .env
├── requirements.txt
├── .env.example             # Template de configuração
│
├── core/
│   ├── bot.py               # Máquina de estados principal
│   ├── hyperliquid_client.py  # API da Hyperliquid (spot + perp)
│   └── risk_manager.py      # Controle de risco + P&L
│
├── utils/
│   ├── logger.py            # Log colorido no terminal + arquivo
│   └── notifier.py          # Notificações Telegram (opcional)
│
└── logs/                    # Logs diários (criado automaticamente)
    └── YYYY-MM-DD.log
```

## Parâmetros importantes (.env)

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `TOTAL_CAPITAL_USDC` | 1000 | Capital total alocado |
| `CAPITAL_ALLOCATION` | 0.80 | % do capital usado (20% de reserva) |
| `FUNDING_ENTRY_THRESHOLD` | 0.003 | Funding mín. para entrar (0.3%/8h) |
| `FUNDING_EXIT_THRESHOLD` | 0.001 | Funding mín. para manter (0.1%/8h) |
| `ALLOWED_ASSETS` | BTC,ETH,SOL | Ativos permitidos |
| `MAX_DELTA_DRIFT_PCT` | 2.0 | % de drift antes de rebalancear |
| `MAX_DRAWDOWN_PCT` | 5.0 | Stop loss de drawdown |
| `SCAN_INTERVAL_SECONDS` | 1800 | Freq. de scan (30 minutos) |

## Taxas da Hyperliquid (maker)

```
Spot:  0.040% por lado  →  0.080% round-trip
Perp:  0.015% por lado  →  0.030% round-trip
Total: 0.110% para abrir + fechar a posição
```

**Ponto de equilíbrio:** funding > 0.11%/ciclo (0.11% para um único ciclo de 8h)
**Threshold padrão do bot:** 0.30%/8h → segurança de 3x acima do break-even

## Retorno estimado

| Capital | Funding média | Retorno/mês | Retorno/ano |
|---|---|---|---|
| $1,000 | 0.3%/8h | $9 | $108 |
| $5,000 | 0.3%/8h | $45 | $540 |
| $10,000 | 0.3%/8h | $90 | $1,080 |
| $50,000 | 0.3%/8h | $450 | $5,400 |
| $100,000 | 0.3%/8h | $900 | $10,800 |

Em mercados bullish com funding alta (0.5–1.0%/8h), os retornos dobram ou triplicam.

## Riscos

1. **Funding negativa**: se virar negativa, você paga em vez de receber. O bot sai automaticamente.
2. **Liquidação do perp**: improvável com o ratio usado (50% spot / 50% margem perp), mas possível em movimentos extremos. Configure margem isolada no Hyperliquid.
3. **Smart contract**: risco inerente de qualquer DEX. Use uma carteira dedicada, nunca a principal.
4. **Slippage**: em ativos de baixa liquidez o spread come o lucro. O bot usa apenas BTC, ETH, SOL por padrão.

## Notificações Telegram (opcional)

1. Crie um bot no Telegram via @BotFather → copie o token
2. Mande uma mensagem pro bot e pegue seu chat_id via `https://api.telegram.org/bot{TOKEN}/getUpdates`
3. Preencha `TELEGRAM_BOT_TOKEN` e `TELEGRAM_CHAT_ID` no `.env`

---

**Aviso:** Este software é para fins educacionais. Trading envolve risco de perda. Sempre teste com pequenas quantias primeiro.
