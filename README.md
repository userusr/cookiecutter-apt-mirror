# Cookiecutter apt-mirror

Шаблон [cookiecutter][audreyr_cookiecutter] для создания локальной копии
репозиториев [APT][wiki_apt].

В очередной раз устанавливая `Ubuntu` в изолированной от Интернета сети,
перечитал [руководство][create_local_repo] и решил немного автоматизировать этот
процесс с помощью шаблона [cookiecutter][audreyr_cookiecutter]. Во-первых, я
хочу чтобы конфигурация `apt-mirror` лежала вместе с зеркалом. Во-вторых, нужны
открытые ключи репозиториев, чтобы `APT` не ругался на невозможность [проверки
подписи][secureapt]. В-третьих, для работы `APT` по сети мне было достаточно
встроенного в `python` модуля [http.server][python_http_server].

Основная настройка [apt-mirror][github_apt_mirror] - каталог `base_path`, путь
где будет создано зеркало. `base_path` устанавливается автоматически на корень
шаблона.

Скрипт `var/gpg-keys` находит в файлах `InRelease` каталога `mirror`
идентификаторы открытых ключей `GPG`, скачивает их и экспортирует в папку
`mirror/keys`.

## Для чего нужен

- создает структуру папок для `apt-mirror`;
- устанавливает корневую папку зеркала `base_path`;
- загружает открытые ключи подписи репозиториев;
- стартует `http.server` сервер для установки по сети.

## Как использовать

[Установить][cookiecutter_install_page] `cookiecutter`:

``` bash
$ pip install -U cookiecutter
```

Перейти в папку, где планируется создать зеркало, например, на внешнем HDD:

``` bash
$ cd /media/$USER/repo
$ cookiecutter https://github.com/userusr/cookiecutter-apt-mirror.git
```

По-умолчанию проект будет называться `apt_local_mirror`

``` bash
$ cd apt_locat_mirror
```

Добавить в файл `etc/mirror.list` нужные репозитории и создать зеркало:

``` bash
$ make mirror
```

На машине, где планируется установка, добавить в `/etc/apt/sources.list`
локальные источники пакетов. Это могут быть `file:///` (если файлы доступны
локально) или `http`.

Чтобы запустить `http-server`:

``` bash
$ make http-server
```

## Проблемы `apt-mirror`

### Проблема с `binary-i386`

При обновлении из локальной копии `APT` не находит пакетов `binary-i386`:

```
Err:8 file:/.../ubuntu bionic/main i386 Packages
File not found - /.../ubuntu/dists/bionic/main/binary-i386/Packages (2: No such file or directory)
```

Проблема [решается][failed_to_fetch_file_binary_i386] добавлением `[arch=amd64]`
к записи локальной копии репозитория.

### Проблема с языковыми пакетами

При обновлении из локальной копии `APT` не находит языковых пакетов:

```
Err:8 file:/.../ubuntu bionic/main Translation-en
File not found - /.../ubuntu/dists/bionic/main/i18n/Translation-en (2: No such file or directory)
```

[Содержимое][remmina_next_ppa_i18n] папки `i18n`:

```
/...
    └──i18n
        ├── Index
        ├── Translation-en.gz
        └── Translation-en.xz
```

Содержимое файла `Index`:

```
SHA1:
 b2815de6a357b8b1406f9bb4cb3002019a937a89 15319 Translation-en
 22c776937b971261b2859f086b16cb6866cc4010  2483 Translation-en.gz
 4fff21c01e667869abe39dafc31ba18b8f8c3b2c  2484 Translation-en.xz
```

То есть файл `Translation-en` должен быть, но вместо этого есть только его
сжатая копия. [Решается][speed_up_apt] с помощью `Acquire::Languages` или опции
`[lang=none]`.


[audreyr_cookiecutter]: https://github.com/audreyr/cookiecutter
[create_local_repo]: https://wiki.debian.org/ru/CreateLocalRepo
[failed_to_fetch_file_binary_i386]: https://askubuntu.com/questions/394653/ubuntu_64_bit_failed_to_fetch_file_binary_i386_packages_error_while_updat 
[speed_up_apt]: https://askubuntu.com/questions/217502/speed_up_apt_get_update_by_removing_known_ignored_translation_en
[remmina_next_ppa_i18n]: http://ppa.launchpad.net/remmina-ppa-team/remmina-next/ubuntu/dists/bionic/main/i18n/
[github_apt_mirror]: https://github.com/apt-mirror/apt-mirror
[wiki_apt]: https://en.wikipedia.org/wiki/APT_(Package_Manager)
[cookiecutter_install_page]: http://cookiecutter.readthedocs.org/en/latest/installation.html
[python_http_server]: https://docs.python.org/3.6/library/http.server.html
[secureapt]: https://wiki.debian.org/SecureApt
