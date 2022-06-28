
rule nextclade_dataset:
    output:
        temp("mpxv.zip"),
    shell:
        """
        nextclade2 dataset get --name MPXV --output-zip {output}
        """


rule reverse_reversed_sequences:
    input:
        metadata="data/metadata_raw.tsv",
        sequences="data/sequences.fasta",
    output:
        "data/sequences_reversed.fasta",
    shell:
        """
        python3 bin/reverse_reversed_sequences.py \
            --metadata {input.metadata} \
            --sequences {input.sequences} \
            --output {output}
        """


rule nextclade:
    input:
        sequences="data/sequences_reversed.fasta",
        dataset="mpxv.zip",
    output:
        "data/nextclade.tsv",
    threads: 4
    shell:
        """
        nextclade2 run -D {input.dataset} -j {threads} --output-tsv {output} {input.sequences}
        """


rule join_metadata_clades:
    input:
        nextclade="data/nextclade.tsv",
        metadata="data/metadata_raw.tsv",
    output:
        "data/metadata.tsv",
    params:
        id_field=config["transform"]["id_field"],
    shell:
        """
        python3 bin/join-metadata-and-clades.py \
                --id-field {params.id_field} \
                --metadata {input.metadata} \
                --nextclade {input.nextclade} \
                -o {output}
        """
