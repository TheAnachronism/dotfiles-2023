USE_LINUXBREW=0
USE_KUBERNETES=0
USE_DOTNET=0


if [ "$USE_LINUXBREW" -eq 1 ]; then
  export PATH=/home/linuxbrew/.linuxbrew/bin/:$PATH
fi

if [ "$USE_DOTNET" -eq 1 ]; then
  export PATH=~/.dotnet/tools/:$PATH
fi
