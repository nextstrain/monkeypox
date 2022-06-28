"""
This part of the workflow handles transforming the data into standardized
formats and expects input file

    sequences_ndjson = "data/sequences.ndjson"

This will produce output files as

    metadata = "data/metadata.tsv"
    sequences = "data/sequences.fasta"

Parameters are expected to be defined in `config.transform`.
"""


rule fetch_general_geolocation_rules:
    output:
        general_geolocation_rules="data/general-geolocation-rules.tsv",
    params:
        geolocation_rules_url=config["transform"]["geolocation_rules_url"],
    shell:
        """
        curl {params.geolocation_rules_url} > {output.general_geolocation_rules}
        """


rule concat_geolocation_rules:
    input:
        general_geolocation_rules="data/general-geolocation-rules.tsv",
        local_geolocation_rules=config["transform"]["local_geolocation_rules"],
    output:
        all_geolocation_rules="data/all-geolocation-rules.tsv",
    shell:
        """
        cat {input.general_geolocation_rules} {input.local_geolocation_rules} >> {output.all_geolocation_rules}
        """


rule transform:
    input:
        sequences_ndjson="data/sequences.ndjson",
        all_geolocation_rules="data/all-geolocation-rules.tsv",
    output:
        metadata="data/metadata_raw.tsv",
        sequences="data/sequences.fasta",
    log:
        "logs/transform.txt",
    params:
        field_map=config["transform"]["field_map"],
        strain_regex=config["transform"]["strain_regex"],
        strain_backup_fields=config["transform"]["strain_backup_fields"],
        date_fields=config["transform"]["date_fields"],
        expected_date_formats=config["transform"]["expected_date_formats"],
        articles=config["transform"]["titlecase"]["articles"],
        abbreviations=config["transform"]["titlecase"]["abbreviations"],
        titlecase_fields=config["transform"]["titlecase"]["fields"],
        authors_field=config["transform"]["authors_field"],
        authors_default_value=config["transform"]["authors_default_value"],
        abbr_authors_field=config["transform"]["abbr_authors_field"],
        annotations=config["transform"]["annotations"],
        annotations_id=config["transform"]["annotations_id"],
        metadata_columns=config["transform"]["metadata_columns"],
        id_field=config["transform"]["id_field"],
        sequence_field=config["transform"]["sequence_field"],
    shell:
        """
        (cat {input.sequences_ndjson} \
            | ./bin/transform-field-names \
                --field-map {params.field_map} \
            | ./bin/transform-string-fields --normalize \
            | ./bin/transform-strain-names \
                --strain-regex {params.strain_regex} \
                --backup-fields {params.strain_backup_fields} \
            | ./bin/transform-date-fields \
                --date-fields {params.date_fields} \
                --expected-date-formats {params.expected_date_formats} \
            | ./bin/transform-genbank-location \
            | ./bin/transform-string-fields \
                --titlecase-fields {params.titlecase_fields} \
                --articles {params.articles} \
                --abbreviations {params.abbreviations} \
            | ./bin/transform-authors \
                --authors-field {params.authors_field} \
                --default-value {params.authors_default_value} \
                --abbr-authors-field {params.abbr_authors_field} \
            | ./bin/apply-geolocation-rules \
                --geolocation-rules {input.all_geolocation_rules} \
            | ./bin/merge-user-metadata \
                --annotations {params.annotations} \
                --id-field {params.annotations_id} \
            | ./bin/ndjson-to-tsv-and-fasta \
                --metadata-columns {params.metadata_columns} \
                --metadata {output.metadata} \
                --id-field {params.id_field} \
                --sequence-field {params.sequence_field} ) 2>> {log}
        """
