# Cookiecutter apt-mirror

Шаблон [cookiecutter][audreyr_cookiecutter] для создания локальной копии
репозиториев `apt`.

## Для чего нужен

Этот шаблон помогает в работе с программой apt-mirror и [локальными
копиями][create_local_repo] репозиториев `apt`:
- создает необходимую структуру папок;
- загружает необходимые ключи GPG.
- стартует http сервер для быстрой установки

## Как использовать

    pip install -U cookiecutter

Перейти в папку, где планируется создать зеркало

    cookiecutter https://github.com/userusr/cookiecutter-apt-mirror.git

По-умолчанию проект будет называться `apt_local_mirror`

    $ cd apt_locat_mirror

Отредактируйте файл `etc/mirror.list`, добавьте нужные репозитории.

    $ nano etc/mirror.list
    $ make mirror

Перенесите папку на машину, где планируется установка.

Добавьте в `/etc/apt/sources.list` локальные источники пакетов. Это могут быть
`file:///` (если файлы доступны локально) или `http`.

Чтобы запустить `http-server`:

    $ make http-server

## Проблемы `apt-mirror`

При обновлении из локальной копии `apt` не находит пакетов `binary-i386`

    Err:8 file:/.../ubuntu bionic/main i386 Packages
    File not found - /.../ubuntu/dists/bionic/main/binary-i386/Packages (2: No such file or directory)

Проблема [решается][failed_to_fetch_file_binary_i386] добавлением `[arch=amd64]`
к записи локальной копии репозитория.

    deb [arch=amd64] file:///.../ubuntu bionic main

При обновлении выдает ошибку

    Err:8 file:/.../ubuntu bionic/main Translation-en
    File not found - /.../ubuntu/dists/bionic/main/i18n/Translation-en (2: No such file or directory)

[Содержимое][remmina_next_ppa_i18n] папки `i18n`:

    /...
        └──i18n
            ├── Index
            ├── Translation-en.gz
            └── Translation-en.xz

Содержимое файла `Index`:

    SHA1:
     b2815de6a357b8b1406f9bb4cb3002019a937a89 15319 Translation-en
     22c776937b971261b2859f086b16cb6866cc4010  2483 Translation-en.gz
     4fff21c01e667869abe39dafc31ba18b8f8c3b2c  2484 Translation-en.xz

То есть файл `Translation-en` должен быть, но вместо этого есть только его
сжатая копия. [Решается][speed_up_apt] с помощью `Acquire::Languages`

    $ sudo apt update -o Acquire::Languages=none

Или в файле `.list`:

    deb [lang=none] file:///.../ubuntu bionic main

Чтобы `APT` не ругался, для каждого репозитория нужно сохранить ключ подписи и
загрузить его на новой машине.

[audreyr_cookiecutter]: https://github.com/audreyr/cookiecutter
[create_local_repo]: https://wiki.debian.org/ru/CreateLocalRepo
[failed_to_fetch_file_binary_i386]: https://askubuntu.com/questions/394653/ubuntu_64_bit_failed_to_fetch_file_binary_i386_packages_error_while_updat 
[speed_up_apt]: https://askubuntu.com/questions/217502/speed_up_apt_get_update_by_removing_known_ignored_translation_en
[remmina_next_ppa_i18n]: http://ppa.launchpad.net/remmina-ppa-team/remmina-next/ubuntu/dists/bionic/main/i18n/
