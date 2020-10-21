%define __jar_repack 0

Name:           nacos
Version:        1.1.3
Release:        1%{?dist}
Summary:        Dynamic Naming and Configuration Service

License:        Apache 2.0
URL:            http://nacos.io/
Source0:        %{name}-server-%{version}.zip

BuildArch:      noarch
Requires:       java

%description
Nacos (official site: http://nacos.io) is an easy-to-use platform designed for dynamic service discovery and configuration and service management.
It helps you to build cloud native applications and microservices platform easily.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/%{name}-%{version}
cp -rp %_builddir/%{name}-%{version}/*  $RPM_BUILD_ROOT/opt/%{name}-%{version}


%files
%defattr(-,root,root)

%license /opt/%{name}-%{version}/LICENSE
%doc /opt/%{name}-%{version}/NOTICE

%config /opt/%{name}-%{version}/conf

%attr(755,root,root) /opt/%{name}-%{version}/bin
%attr(755,root,root) /opt/%{name}-%{version}/target

%clean
rm -rf $RPM_BUILD_ROOT

%post
cat <<EOF > /usr/lib/systemd/system/nacos.service
[Unit]
Description=Nacos server service

[Service]
Type=forking
ExecStart=/opt/nacos-1.1.3/bin/startup.sh -m standalone
ExecStop=/opt/nacos-1.1.3/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nacos

%postun
systemctl disable nacos
if [ -f "/usr/lib/systemd/system/nacos.service" ];then
  rm -f /usr/lib/systemd/system/nacos.service
fi

%changelog
* Tue Oct 20 2020 xw
- first build
