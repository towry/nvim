#!/usr/bin/env bash

luacc -o lua/user/prebundle.lua -i /Users/towry/.config/nvim/lua user.config.init plugins.editor.init
