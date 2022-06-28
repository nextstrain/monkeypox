from packaging import version
from augur.__version__ import __version__ as augur_version
import sys

min_version = "16.0.0"
if version.parse(augur_version) < version.parse(min_version):
    print("This pipeline needs a newer version of augur than you currently have...")
    print(f"Current augur version: {augur_version}. Minimum required: {min_version}")
    sys.exit(1)

if not config:

    configfile: "config/config_hmpxv1.yaml"


build_dir = "results"


auspice_dir = "auspice"


rule all:
    input:
        auspice_json=auspice_dir + f"/{config.get('auspice_name','tree')}.json",
        root_sequence_json=auspice_dir
        + f"/{config.get('auspice_name','')}_root-sequence.json",


rule rename:
    input:
        auspice_json=build_dir + f"/{config.get('build_name')}/tree.json",
        root_sequence=build_dir + f"/{config.get('build_name')}/tree_root-sequence.json",
    output:
        auspice_json=auspice_dir + f"/{config.get('auspice_name','tree')}.json",
        root_sequence_json=auspice_dir
        + f"/{config.get('auspice_name','')}_root-sequence.json",
    shell:
        """
        cp {input.auspice_json} {output.auspice_json}
        cp {input.root_sequence} {output.root_sequence_json}
        """


if config.get("data_source", None) == "lapis":

    include: "workflow/snakemake_rules/download_via_lapis.smk"


else:

    include: "workflow/snakemake_rules/prepare.smk"


include: "workflow/snakemake_rules/chores.smk"


include: "workflow/snakemake_rules/core.smk"


rule clean:
    message:
        "Removing directories: {params}"
    params:
        build_dir,
        auspice_dir,
    shell:
        "rm -rfv {params}"


rule cleanall:
    message:
        "Removing directories: {params}"
    params:
        build_dir,
        auspice_dir,
        "data",
    shell:
        "rm -rfv {params}"
