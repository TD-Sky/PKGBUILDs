#!/usr/bin/bash

export launchTarget="/opt/bytedance/feishu/bytedance-feishu"
if [ ${XDG_SESSION_TYPE} = "wayland" ]; then
    export launchTarget="${launchTarget} --ozone-platform-hint=auto --enable-features=UseOzonePlatform --enable-wayland-ime --gtk-version=4"
    export waylandOnly=${waylandOnly:-"true"}
fi

export _portableConfig="/usr/lib/portable/info/com.bytedance.feishu/config"

portable $@
