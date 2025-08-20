#!/usr/bin/bash

export _portableConfig="/usr/lib/portable/info/com.bytedance.feishu/config"

# Double dash is important!
exec portable -- $@
