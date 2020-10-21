Name:           nginx
Version:        1.19.3
Release:        1%{?dist}
Summary:        nginx [engine x]

License:        BSD
URL:            http://nginx.org
Source0:        nginx-1.19.3.tar.gz

BuildRequires:  make gcc
Requires:       pcre-devel openssl-devel zlib-devel

%description
nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server,
and a generic TCP/UDP proxy server, originally written by Igor Sysoev. For a long time,
it has been running on many heavily loaded Russian sites including Yandex, Mail.Ru, VK, and Rambler.
According to Netcraft, nginx served or proxied 25.76% busiest sites in September 2020.
Here are some of the success stories: Dropbox, Netflix, Wordpress.com, FastMail.FM.

%prep
%setup -q

%build
./configure --prefix=/opt/%{name}-%{version}
%make_build

%install
rm -rf $RPM_BUILD_ROOT
%make_install

%files
%defattr(-,root,root)

%attr(755,root,root) /opt/%{name}-%{version}/sbin/nginx
%config /opt/%{name}-%{version}/conf
/opt/%{name}-%{version}/logs
/opt/%{name}-%{version}/html

%clean
rm -rf $RPM_BUILD_ROOT

%post
cat <<EOF > /usr/lib/systemd/system/nginx.service
[Unit]
Description=Nginx service

[Service]
Type=forking
ExecStart=/opt/nginx-1.19.3/sbin/nginx
ExecReload=/opt/nginx-1.19.3/sbin/nginx -s reload
ExecStop=/opt/nginx-1.19.3/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nginx

%postun
systemctl disable nginx
if [ -f "/usr/lib/systemd/system/nginx.service" ];then
  rm -f /usr/lib/systemd/system/nginx.service
fi

%changelog
* Tue Oct 20 2020 xw
- first build
