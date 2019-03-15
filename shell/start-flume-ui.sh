#!/bin/bash
f_pid() {
  pid=`jps | grep vap-flume-ui*.jar | awk '{print $1}'`
  if [ -z "$pid" ] ;then
  	echo 0
  else
  	echo $pid
  fi
}

f_fix() {
  val_input=$1
  val_default=$2
  if [ -z "$val_input" ] ;then
    echo $val_default
  else
    echo $val_input
  fi
}

f_default_home() {
  os=`uname`
  if [[ ${#os} -gt 6 ]] && [[ "${os:0:6}" = "CYGWIN" ]] ;then
  	echo `cygpath -w $(pwd)`
  else
  	echo $(pwd)
  fi
}

f_help() {
  cat <<EOF
示例: $0 <命令> [可选参数]...

命令:
  help                      显示帮助
  start                     启动flume web管理页面
  stop                      关闭flume web管理页面
  status                    flume web管理页面运行状态
  
start 参数:
  --home,-h                 flume web管理页面所在目录,默认路径`f_default_home`
  --auth,-a                 登录验证开关,默认值false
  --auth-url,-au            授权认证服务器接口地址,默认值http://localhost:8080/token/confirmation
  --port,-p                 flume web管理页面访问端口,默认值18080
  --max-allow-memory,-mam   所有flume agent允许使用的最大内存总和,默认值61440MB
  --daemon,-d               后台启动
  --force,-f                强制启动
  
stop 参数:
  --force                   强制关闭,kill -9 pid
  
EOF
}

f_check() {
  echo ""
  app=`ls $1 | grep vap-flume-ui*.jar`
  if [ -f "$1/$app" ] ;then
    if [ -r "$1/$app" -a -w "$1/$app" -a -x "$1/$app" ] ;then
      echo "check $1/$app        ··················OK"
	else
	  chmod 755 "$1/$app"
	  echo "fix $1/$app        ··················OK"
	fi
  else
  	echo "check $1/vap-flume-ui*.jar        ··················FAIL"
  	return 0
  fi
  app2="flume/bin/flume-ng"
  if [ -f "$1/$app2" ] ;then
    if [ -r "$1/$app2" -a -w "$1/$app2" -a -x "$1/$app2" ] ;then
      echo "check $1/$app2        ··················OK"
	else
	  chmod 755 "$1/$app2"
	  echo "fix $1/$app2        ··················OK"
	fi
  else
  	echo "check $1/$app2        ··················FAIL"
  	return 0
  fi
  return 1
}

f_start() {
  pid=`f_pid`
  if [[ 0 = "$pid" ]] || [[ 1 = "$7" ]];then
  	export FLUME_UI_AUTH=$1
    export FLUME_UI_HOME=$2
    export FLUME_UI_PORT=$3
    export MAX_ALLOW_MEM=$4
    export FLUME_UI_AUTH_URL=$6
    echo FLUME_UI_AUTH=$FLUME_UI_AUTH
	echo FLUME_UI_AUTH_URL=$FLUME_UI_AUTH_URL
    echo FLUME_UI_HOME=$FLUME_UI_HOME
    echo FLUME_UI_PORT=$FLUME_UI_PORT
    echo MAX_ALLOW_MEM=$MAX_ALLOW_MEM'MB'
    f_check $2
    stat=$?
    if [[ 1 = "$stat" ]] ;then
	  app=`ls $2 | grep vap-flume-ui*.jar`
      if [ 1 = $5 ] ;then
	    java -jar $FLUME_UI_HOME/$app > /dev/null &
      else
        java -jar $FLUME_UI_HOME/$app
      fi
    fi
  else
    echo "程序已启动,进程ID:"$pid
  fi
}

f_stop() {
  pid=`f_pid`
  if [ 0 = "$pid" ] ;then
	echo "程序未启动"
  else
	os=`uname`
	if [[ ${#os} -gt 6 ]] && [[ "${os:0:6}" = "CYGWIN" ]] ;then
	  taskkill /F /PID $pid
	else
	  kill -$1 $pid
	fi
  fi
}

f_status() {
  pid=`f_pid`
  if [ 0 = "$pid" ] ;then 
    echo "程序未启动" 
  else 
    echo "程序运行中,进程ID:"$pid
  fi
}

cmd=$1

case "$cmd" in
  start)
	while [ -n "$*" ] ;do
	arg=$1
	shift
	  case $arg in
	    --home|-h)
		  ui_home=$1
		  shift
		;;
		--auth|-a)
		  ui_auth=$1
		  shift
		;;
		--auth-url|-au)
		  ui_auth_url=$1
		  shift
		;;
		--port|-p)
		  ui_port=$1
		  shift
		;;
		--max-allow-memory|-mam)
		  mam=$1
		  shift
		;;
		--daemon|-d)
		  daemon=1
		;;
        --force|-f)
		  force=1
		;;
	  esac
	done
	ui_home=`f_fix $ui_home $(f_default_home)`
	ui_auth=`f_fix $ui_auth "false"`
	ui_port=`f_fix $ui_port 28080`
	mam=`f_fix $mam 61400`
	daemon=`f_fix $daemon 0`
	force=`f_fix $force 0`
	ui_auth_url=`f_fix $ui_auth_url "http://localhost:8080/token/confirmation"`
    f_start $ui_auth $ui_home $ui_port $mam $daemon $ui_auth_url $force
  ;;
  stop)
    if [ "$2" = "--force" ] ;then
	  sign=9
	else
	  sign=15
	fi
    f_stop $sign
  ;;
  status)
    f_status
  ;;
  *)
    f_help
  ;;
esac