rule download:
    message: "Downloading sequences and metadata from data.nextstrain.org"
    output:
        sequences = "data/{build_name}_sequences.fasta.xz",
        metadata = "data/{build_name}_metadata.tsv.gz"
    params:
        sequences_url = "https://data.nextstrain.org/files/workflows/monkeypox/sequences.fasta.xz",
        metadata_url = "https://data.nextstrain.org/files/workflows/monkeypox/metadata.tsv.gz"
    shell:
        """
        curl -fsSL --compressed {params.sequences_url:q} --output {output.sequences}
        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
        """

rule decompress:
    message: "Decompressing sequences and metadata"
    input:
        sequences = "data/{build_name}_sequences.fasta.xz",
        metadata = "data/{build_name}_metadata.tsv.gz"
    output:
        sequences = "data/{build_name}_sequences.fasta",
        metadata = "data/{build_name}_metadata.tsv"
    shell:
        """
        gzip --decompress --keep {input.metadata}
        xz --decompress --keep {input.sequences}
        """
