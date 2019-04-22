# RPM 包制作
-------

依赖命令
rpmbuild
rpmdevtools

生成目录
rpmdev-setuptree
目录名|说明|macros中的宏名
---|---|---
BUILD|编译rpm包的临时目录|%_builddir
BUILDROOT|编译后生成的软件临时安装目录|%_buildrootdir
RPMS|最终生成的可安装rpm包的所在目录|%_rpmdir
SOURCES|所有源代码和补丁文件的存放目录|%_sourcedir
SPECS|存放SPEC文件的目录(重要)|%_specdir
SRPMS|软件最终的rpm源码格式存放路径(暂时忽略掉，别挂在心上)|%_srcrpmdir

生成spec文件
rpmdev-newspec -o Name-version.spec

```
%define __jar_repack 0
%define _v_path /usr/hdp/2.4.0.0-169
Name:           vap_flume
Version:        2.0
Release:        1%{?dist}
Summary:        vrv audit platform flume

License:        GPL
URL:            http://www.vrv.com.cn
Source0:        vap_flume-2.0.zip

%description
data collect tool

%prep
%setup -q

%install
mkdir -p $RPM_BUILD_ROOT/usr/hdp/2.4.0.0-169/vap-flume
cp -rp %_builddir/%{name}-%{version}/*  $RPM_BUILD_ROOT/usr/hdp/2.4.0.0-169/vap-flume

%files
%defattr(-,root,root)
%_v_path/vap-flume/start-flume-ui.sh
%_v_path/vap-flume/vap-flume-ui.jar
%_v_path/vap-flume/flume/bin
%_v_path/vap-flume/flume/lib
%_v_path/vap-flume/flume/logs
%_v_path/vap-flume/flume/tools

%config
%_v_path/vap-flume/flume/conf/

%doc
%_v_path/vap-flume/flume/CHANGELOG
%_v_path/vap-flume/flume/DEVNOTES
%_v_path/vap-flume/flume/doap_Flume.rdf
%_v_path/vap-flume/flume/LICENSE
%_v_path/vap-flume/flume/NOTICE
%_v_path/vap-flume/flume/README.md
%_v_path/vap-flume/flume/RELEASE-NOTES

%clean
rm -rf $RPM_BUILD_ROOT

%pre
pids=`ps -ef | grep %_v_path/vap-flume | awk '{print $2}'`
if [[ "" != "$pids" ]] ;then
  kill -9 $pids
fi

%post
chmod 755 %_v_path/vap-flume/start-flume-ui.sh

%preun
pids=`ps -ef | grep %_v_path/vap-flume | awk '{print $2}'`
if [[ "" != "$pids" ]] ;then
  kill -9 $pids
fi

%postun
rm -rf %_v_path/vap-flume/
```