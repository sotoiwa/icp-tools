#/bin/bash
#
# Workspacesを作成するスクリプト

# 引数で渡されたファイル全体を変数に格納
json_file=$(cat $1)

# Workspacesの配列の長さを取得
len=$(echo ${json_file} | jq -r '.Workspaces | length')

while true; do

  count=0

  response=$(aws workspaces describe-workspaces)

  for i in $( seq 0 $(($len - 1)) ); do

    directory_id=$(echo ${json_file} | jq -r '.Workspaces['$i'].DirectoryId')
    user_name=$(echo ${json_file} | jq -r '.Workspaces['$i'].UserName')

    state=$(echo $response | jq -r '.Workspaces[] | select ( .UserName == "'${user_name}'" and .DirectoryId == "'${directory_id}'") | .State')
    workspace_id=$(echo $response | jq -r '.Workspaces[] | select ( .UserName == "'${user_name}'" and .DirectoryId == "'${directory_id}'") | .WorkspaceId')
    echo "DirectoryId: ${directory_id}, UserName: ${user_name}, WorkspaceId: ${workspace_id}, State: ${state}: "

    if [ -z ${state} ]; then
      # Workspaceが存在しなければ作成を実行
      echo "Workspaceを作成します。(DirectoryId: ${directory_id}, UserName: ${user_name}"
      json=$(echo ${json_file} | jq -r '[ .Workspaces[] | select ( .UserName == "'${user_name}'" and .DirectoryId == "'${directory_id}'") ]')
      echo $json
      aws workspaces create-workspaces --workspaces "${json}"
    elif [ ${state} = "ERROR" ]; then
      # ERRORだったら削除
      echo "Workspaceを削除します。(WorkspaceId :${workspace_id}"
      aws workspaces terminate-workspaces --terminate-workspace-requests ${workspace_id}
    elif [ ${state} = "AVAILABLE" ] || [ ${state} = "STARTING" ]; then
      # 作成完了
      (( count++ ))
    elif [ ${state} = "STOPPED" ] || [ ${state} = "STOPPING" ]; then
      # 作成完了
      (( count++ ))
    fi

  done

  echo "作成済みのWorkspaseの数: $count"
  echo "作成予定のWorkspacesの数: $len"

  if [ $count -eq $len ]; then
    break
  fi

  echo "60秒Sleepします。"
  sleep 60

done
