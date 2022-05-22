#!/usr/bin/env lua

-- dockgen       Simple docker generator
-- Copyright (c) 2022 Christophe Delord <http:/cdelord.fr>
--               All Rights Reserved
--
-- This library is free software. It comes without any warranty, to
-- the extent permitted by applicable law. You can redistribute it
-- and/or modify it under the terms of the Do What the Fuck You Want
-- to Public License, Version 2, as published by Sam Hocevar. See
-- http://www.wtfpl.net/ for more details.

local OS = arg[1]
local OS_VERSION = arg[2]

local fedora = OS == "fedora"
local debian = OS == "debian"
local ubuntu = OS == "ubuntu"
local archlinux = OS == "archlinux"

assert(fedora or debian or ubuntu or archlinux, "Unknown OS: "..OS)

local lapp, upp, panda
local LAPP_VERSION = "N/A"

do
    local i = 3
    while i <= #arg do
        if arg[i] == "lapp" then lapp = true; LAPP_VERSION = arg[i+1]; i = i+2;
        elseif arg[i] == "upp" then upp = true; i = i+1;
        elseif arg[i] == "panda" then panda = true; i = i+1;
        else error("Unknown module: "..arg[i])
        end
    end
end

if upp then assert(lapp, "upp requires lapp") end

local function when(cond)
    return function(t)
        return cond and t or {}
    end
end

local function flatten(...)
    local xs = {}
    local function f(...)
        for i = 1, select("#", ...) do
            local x = select(i, ...)
            if type(x) == "table" then
                f(table.unpack(x))
            else
                table.insert(xs, x)
            end
        end
    end
    f(...)
    return xs
end

local TAG = table.concat(flatten {
    OS, OS_VERSION,
    when(lapp) {"lapp", LAPP_VERSION},
    when(upp) "upp",
    when(panda) "panda",
}, "-")

local dockerfile = table.concat(flatten {
    "FROM "..OS..":"..OS_VERSION.." as "..TAG,
    'RUN useradd -Um user; echo "user  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers',
    when(fedora) {
        "RUN dnf install -y git make gcc which readline-devel wget hostname diffutils which mingw64-gcc zip graphviz",
    },
    when(debian or ubuntu) {
        "RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Europe/Paris apt install -y git make gcc libreadline-dev wget gcc-mingw-w64 zip graphviz",
    },
    when(archlinux) {
        "RUN pacman -Sy --noconfirm",
        "RUN pacman -S --noconfirm git make gcc readline wget inetutils diffutils which mingw-w64-gcc zip graphviz",
    },
    when(lapp) {
        "RUN git clone https://github.com/CDSoft/lapp && ( cd lapp && git checkout "..LAPP_VERSION.." && make submodules && CHECKS=OFF make linux windows && PREFIX=/usr/bin CHECKS=OFF make install ) && rm -rf lapp",
    },
    when(upp) {
        "RUN git clone https://github.com/CDSoft/upp && lapp upp/upp.lua -o /usr/bin/upp && rm -rf upp",
    },
    when(panda) {
        "RUN wget http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O /usr/bin/plantuml.jar",
        "RUN git clone https://github.com/CDSoft/panda && install panda/panda.lua /usr/bin/panda.lua && install panda/panda /usr/bin/panda && rm -rf panda",
    },
    "USER user",
    "WORKDIR /mnt/app",
    ""
}, "\n")

local p = assert(io.popen("docker build -t="..TAG.." - 1>&2", "w"))
p:write(dockerfile)
local ok, _, code = p:close()

if not ok then os.exit(code) end

print(TAG)
