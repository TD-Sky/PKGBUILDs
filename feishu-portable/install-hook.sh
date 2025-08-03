#!/bin/sh

set -xve

ln -sfr /usr/lib/feishu-portable/feishu.sh /usr/bin/feishu
ln -sfr /usr/lib/feishu-portable/feishu.sh /usr/bin/bytedance-feishu-stable
ln -sfr /dev/null /usr/share/applications/feishu.desktop
sed -i 's#command="/opt/bytedance/feishu/feishu"#command="/usr/bin/feishu"#' /usr/share/menu/feishu.menu
