%define __jar_repack 0

Name:           cmak
Version:        3.0.0.5
Release:        1%{?dist}
Summary:        A tool for managing Apache Kafka

License:        Apache 2.0
URL:            http://nacos.io/
Source0:        %{name}-%{version}.zip

BuildArch:      noarch
Requires:       java

%description
A tool for managing Apache Kafka.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/%{name}-%{version}
cp -rp %_builddir/%{name}-%{version}/*  $RPM_BUILD_ROOT/opt/%{name}-%{version}


%files
%defattr(-,root,root)

%attr(755,root,root) /opt/%{name}-%{version}/bin
%config /opt/%{name}-%{version}/conf
%attr(755,root,root) /opt/%{name}-%{version}/lib
/opt/%{name}-%{version}/share
%doc /opt/%{name}-%{version}/README.md

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Oct 20 2020 xw
- first build
