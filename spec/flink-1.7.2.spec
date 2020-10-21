%define __jar_repack 0

Name:           flink
Version:        1.7.2
Release:        1%{?dist}
Summary:        Apache Flink

License:        Apache 2.0
URL:            https://flink.apache.org
Source0:        %{name}-%{version}-bin-hadoop27-scala_2.11.tgz

BuildArch:      noarch

%description
Apache Flink is a framework and distributed processing engine for stateful computations over unbounded and bounded data streams.
Flink has been designed to run in all common cluster environments, perform computations at in-memory speed and at any scale.

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
/opt/%{name}-%{version}/examples/batch
/opt/%{name}-%{version}/examples/gelly
/opt/%{name}-%{version}/examples/python/batch
/opt/%{name}-%{version}/examples/python/streaming
/opt/%{name}-%{version}/examples/streaming
/opt/%{name}-%{version}/lib
/opt/%{name}-%{version}/licenses
/opt/%{name}-%{version}/log
/opt/%{name}-%{version}/opt
%license /opt/%{name}-%{version}/LICENSE
%doc /opt/%{name}-%{version}/NOTICE
%doc /opt/%{name}-%{version}/README.txt

%clean
rm -rf $RPM_BUILD_ROOT

%post
chmod +x /opt/%{name}-%{version}/examples/python/batch/*
chmod +x /opt/%{name}-%{version}/examples/python/streaming/*

%changelog
* Tue Oct 20 2020 xw
- first build
