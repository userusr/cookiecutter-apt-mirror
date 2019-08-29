#!/usr/bin/env python
import os

PROJECT_DIRECTORY = os.path.realpath(os.path.curdir)
APT_MIRROR_CONF = os.path.join(PROJECT_DIRECTORY, 'etc/mirror.list')

if __name__ == '__main__':
    with open(APT_MIRROR_CONF) as f:
        content = f.read()

    content = content.replace('$((BASE_PATH))', PROJECT_DIRECTORY)

    with open(APT_MIRROR_CONF, 'w') as f:
        f.write(content)

