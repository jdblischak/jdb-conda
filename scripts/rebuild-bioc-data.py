#/usr/bin/env python

"""Rebuild Bioconductor data packages.

Helper script for https://github.com/bioconda/bioconda-utils/issues/235

usage: python rebuild-bioc-data.py recipe_folder config package_list

recipe_folder: path to recipes, e.g. bioconda-recipes/recipes/

config: path to config yaml file, e.g. bioconda-recipes/config.yaml

package_list: plain text file with one bioconda package per line,
e.g. bioconductor-affydata
"""

from bioconda_utils.bioconductor_skeleton import write_recipe
from conda_build.metadata import MetaData
import os
import sys

args = sys.argv[1:]
recipe_folder = args[0]
config = args[1]
package_list = args[2]

assert os.path.exists(recipe_folder), "Recipe folder exists"
assert os.path.exists(config), "Config file exists"
assert os.path.exists(package_list), "Package list file exists"

handle = open(package_list, "r")

for line in handle:
    pkg = line.strip()
    metafile = recipe_folder + "/" + pkg + "/meta.yaml"
    assert os.path.exists(metafile), "meta.yaml exists for %s"%(pkg)
    metadata = MetaData(metafile)
    # Get the package name (capitalized correctly), version, and Bioconductor
    # release from the meta.yaml file. The purpose of this script is to fix
    # existing recipes, not to update the package to the latest version.
    name, version = metadata.get_value("source/fn").rstrip(".tar.gz").split("_")
    bioc = metadata.get_value("source/url")[0].split("/")[4]
    sys.stderr.write("Writing recipe for %s %s (%s)\n"%(name, version, bioc))
    write_recipe(package = name,
                 recipe_dir = recipe_folder,
                 config = config,
                 force = True,
                 bioc_version = bioc,
                 pkg_version = version)

handle.close()
