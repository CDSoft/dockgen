# Docker generator

## Introduction

> [!WARNING]
> This repository is no longer maintained and has been archived.
>
> Please consider using [LuaX](https://github.com/CDSoft/LuaX) and [pub](https://github.com/CDSoft/pub) instead.

`dockgen.lua` generate a docker that can be used to build
[LAPP](https://github.com/CDSoft/lapp),
[UPP](https://github.com/CDSoft/upp),
and more.

## Usage

```sh
$ dockgen.lua <OS> <OS_VERSION> [lapp <LAPP_VERSION>] [upp] [panda]
```

`dockgen.lua` generates a docker and prints the docker tag.

Available OSes:

- fedora
- debian
- ubuntu
- archlinux

The new docker can then be run:

```sh
$ docker run -t -i <TAG>
```

## Example

```sh
$ TAG=$(dockgen.lua fedora 36 lapp 0.6.3 upp panda)
$ docker run -t -i $TAG
```

## More information

Read the source Luke!

## License

    # dockgen       Simple docker generator
    # Copyright (c) 2022 Christophe Delord <http:/cdelord.fr>
    #               All Rights Reserved
    #
    # This library is free software. It comes without any warranty, to
    # the extent permitted by applicable law. You can redistribute it
    # and/or modify it under the terms of the Do What the Fuck You Want
    # to Public License, Version 2, as published by Sam Hocevar. See
    # http://www.wtfpl.net/ for more details.
