#!/bin/bash
wget -q https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/services/main.htm -O /usr/lib/lua/luci/view/serviceinstaller/main.htm
/etc/init.d/uhttpd restart
