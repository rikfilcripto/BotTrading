@echo off
title HyperEdge Bot — Diagnostico
cd /d "%~dp0"

echo.
echo  ============================================
echo   HyperEdge Bot — Diagnostico de Problemas
echo  ============================================
echo.

:: === 1. Verificar Python ===
echo  [1] Verificando Python...
python --version 2>&1
if errorlevel 1 (
    echo      ERRO: 'python' nao encontrado.
    echo      Tentando 'py'...
    py --version 2>&1
    if errorlevel 1 (
        echo      ERRO: 'py' tambem nao encontrado.
        echo      Instale Python 3.10+ em python.org
        echo      e marque "Add Python to PATH".
        goto :fim
    ) else (
        echo      OK: 'py' encontrado. Use 'py app.py' no lugar de 'python app.py'
    )
) else (
    echo      OK.
)
echo.

:: === 2. Verificar pasta atual ===
echo  [2] Pasta atual:
echo      %CD%
echo.

:: === 3. Verificar arquivos essenciais ===
echo  [3] Arquivos essenciais:
for %%f in (app.py config.py version.py requirements.txt) do (
    if exist "%%f" (
        echo      OK: %%f
    ) else (
        echo      FALTANDO: %%f
    )
)
echo.

:: === 4. Verificar dependencias ===
echo  [4] Dependencias instaladas:
python -c "import tkinter; print('     OK: tkinter')" 2>nul || echo      FALTA: tkinter
python -c "import hyperliquid; print('     OK: hyperliquid')" 2>nul || echo      FALTA: hyperliquid  ^(pip install -r requirements.txt^)
python -c "import eth_account; print('     OK: eth_account')" 2>nul || echo      FALTA: eth_account
python -c "import dotenv; print('     OK: python-dotenv')" 2>nul || echo      FALTA: python-dotenv
echo.

:: === 5. Tentar importar modulos criticos ===
echo  [5] Testando importacao de modulos...
python -c "import sys; sys.path.insert(0,'.');import version; print('     OK: version.py -', version.FULL_NAME)" 2>&1 || echo      ERRO: version.py falhou
python -c "import sys; sys.path.insert(0,'.');import config; print('     OK: config.py')" 2>&1 || echo      ERRO: config.py falhou
python -c "import sys; sys.path.insert(0,'.');from config import cfg; print('     OK: cfg =', type(cfg).__name__)" 2>&1 || echo      ERRO: 'from config import cfg' falhou
echo.

:: === 6. Capturar erro real do app.py ===
echo  [6] Capturando erro de inicializacao do app.py...
echo      (aguarde 5 segundos...)
echo.

:: Escreve script de teste
echo import sys, os > _teste_import.py
echo sys.path.insert(0, '.') >> _teste_import.py
echo try: >> _teste_import.py
echo     import app >> _teste_import.py
echo     print('OK: app.py importado sem erros