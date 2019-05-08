#/bin/bash

set -eu

COMMAND=kubectl

# コマンドがシンボリックリンクではない場合は終了
if [ ! -L /usr/local/bin/${COMMAND} ]; then
  echo ${COMMAND} is not symbolic link
  exit 1
fi

# 現在のバージョンを表示
echo "Current ${COMMAND} version:"
/usr/local/bin/${COMMAND} version --client
echo ""

# 利用可能なバージョンを表示
echo "Available ${COMMAND} version:"
find -f /usr/local/bin/${COMMAND}* -type f
echo ""

# シンボリックリンクではないファイルについて繰り返し
for v_command in $(find -f /usr/local/bin/${COMMAND}* -type f)
do
  while true
  do
    read -p "${v_command} <- use this version? (y/n/a):" yn
    case $yn in
      [yY]*)
        rm -f /usr/local/bin/${COMMAND}
        ln -s ${v_command} /usr/local/bin/${COMMAND}
        echo "${COMMAND} version changed!"
        echo ""
        echo "Current ${COMMAND} version:"
        /usr/local/bin/${COMMAND} version --client
        echo ""; echo "Done!"; exit ;;
      [nN]*)
        echo "Skip!"; echo ""; break ;;
      [aA]*)
        echo "Abort!"; echo ""; exit ;;
    esac
  done
done
echo "Done!"
