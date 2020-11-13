Name:           redis
Version:        4.0.8
Release:        1%{?dist}
Summary:        REmote DIctionary Server

License:        BSD
URL:            https://redis.io
Source0:        redis-4.0.8.tar.gz

BuildRequires:  make gcc

%description
redis is an open source (BSD licensed), in-memory data structure store, used as a database,
cache and message broker. It supports data structures such as strings, hashes, lists, sets,
sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams.
Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence,
and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.

%prep
%autosetup

%build
make MALLOC=libc

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/%{name}-%{version}
mkdir -p $RPM_BUILD_ROOT/opt/%{name}-%{version}/conf
make install PREFIX=$RPM_BUILD_ROOT/opt/%{name}-%{version}
cp %_builddir/%{name}-%{version}/redis.conf  $RPM_BUILD_ROOT/opt/%{name}-%{version}/conf/redis.conf.example
cp %_builddir/%{name}-%{version}/sentinel.conf  $RPM_BUILD_ROOT/opt/%{name}-%{version}/conf/sentinel.conf.example


%files
%defattr(-,root,root)

%config /opt/%{name}-%{version}/conf
%attr(755,root,root) /opt/%{name}-%{version}/bin/redis-benchmark
%attr(755,root,root) /opt/%{name}-%{version}/bin/redis-check-aof
%attr(755,root,root) /opt/%{name}-%{version}/bin/redis-check-rdb
%attr(755,root,root) /opt/%{name}-%{version}/bin/redis-cli
%attr(755,root,root) /opt/%{name}-%{version}/bin/redis-server
/opt/%{name}-%{version}/bin/redis-sentinel

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Oct 20 2020 xw
- first build
