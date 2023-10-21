#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os, sys

pdir = os.getcwd()

if len(sys.argv) == 2:
    new_name = sys.argv[1]
    for dir in os.listdir(pdir):
        if dir == "lua":
            os.rename(os.path.join("lua", "nvim-plugin-template"), os.path.join("lua",new_name))
        if dir == "plugin":
            os.rename(os.path.join("plugin", "nvim-plugin-template.lua"),
                      os.path.join("plugin",new_name + ".lua"))
        if dir == 'doc':
            os.rename(os.path.join("doc", "nvim-plugin-template.txt"),
                      os.path.join("doc",new_name + ".txt"))
        if dir == '.github':
            with open(os.path.join(".github","workflows","ci.yml"), 'r+') as f:
                d = f.read()
                t = d.replace('nvim-plugin-template', new_name)
                f.seek(0, 0)
                f.write(t)

    choice = input("Do you want also remove example code in init.lua and test (y|n): ")
    if choice.lower() == 'y':
        with open(os.path.join(pdir, 'lua',new_name,'init.lua'), 'w') as f:
            f.truncate()

        with open(os.path.join(pdir, 'test','plugin_spec.lua'), 'w') as f:
            f.truncate()

    os.remove(os.path.join(os.getcwd(), 'rename.py'))
