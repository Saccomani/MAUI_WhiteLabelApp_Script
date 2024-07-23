#!/bin/bash
set -e

# Verifica se o caminho do arquivo ZIP foi fornecido
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <caminho_do_arquivo_zip>"
    exit 1
fi

ZIP_FILE="$1"

# Define o diretório do script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Diretório do script: $DIR"

# Descompacta o arquivo ZIP
unzip -o "$ZIP_FILE" -d "$DIR"
echo "Arquivo ZIP descompactado em: $DIR"

# Mostra o diretório atual
echo "Diretório atual: $(pwd)"

# Calcula o diretório base para 'src/GE.Core'
# Se o script está dentro de 'src/GE.Core/Scripts', subir um nível deve nos levar ao diretório 'src'
BASE_DIR="$(cd "$DIR/../" && pwd)"
echo "Diretório base calculado: $BASE_DIR"

# Verifica se o diretório base existe
if [ ! -d "$BASE_DIR/src/GE.Core" ]; then
    echo "Erro: Diretório base não encontrado. ($BASE_DIR/src/GE.Core)"
    exit 1
fi

# Função para copiar arquivos e confirmar
copy_and_confirm() {
    cp -f "$1" "$2"
    if [ $? -eq 0 ]; then
        echo "Arquivo $1 copiado com sucesso para $2."
    else
        echo "Erro ao copiar $1 para $2."
        exit 1
    fi
}

# Copia os arquivos para as pastas corretas
copy_and_confirm "$DIR/TenantInfo.json" "$BASE_DIR/src/GE.Core/Resources/Raw/"
copy_and_confirm "$DIR/images/splash.svg" "$BASE_DIR/src/GE.Core/Resources/Splash/"
copy_and_confirm "$DIR/images/appicon.svg" "$BASE_DIR/src/GE.Core/Resources/AppIcon/"
copy_and_confirm "$DIR/images/appiconfg.svg" "$BASE_DIR/src/GE.Core/Resources/AppIcon/"
copy_and_confirm "$DIR/images/logo_ultramax_final.svg" "$BASE_DIR/src/GE.Core/Resources/Images/"

# Arquivos de push
copy_and_confirm "$DIR/push/google-services.json" "$BASE_DIR/src/GE.Core"
copy_and_confirm "$DIR/push/GoogleService-Info.plist" "$BASE_DIR/src/GE.Core"

# Troca os manifestos
copy_and_confirm "$DIR/infos/AndroidManifest.xml" "$BASE_DIR/src/GE.Core/Platforms/Android"
copy_and_confirm "$DIR/infos/Info.plist" "$BASE_DIR/src/GE.Core/Platforms/iOS"
copy_and_confirm "$DIR/infos/Entitlements.plist" "$BASE_DIR/src/GE.Core/Platforms/iOS"

# Remover arquivos descompactados
echo "Removendo arquivos descompactados..."
rm -rf "$DIR/TenantInfo.json" "$DIR/images" "$DIR/push" "$DIR/infos" "$DIR/__MACOSX"
echo "Arquivos descompactados removidos."

# Reporta status
echo "Arquivos copiados e limpeza concluída com sucesso!"
