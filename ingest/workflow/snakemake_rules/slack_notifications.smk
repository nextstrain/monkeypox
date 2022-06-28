"""
This part of the workflow handles various Slack notifications.
Designed to be used internally by the Nextstrain team with hard-coded paths
to files on AWS S3.

All rules here require two environment variables:
    * SLACK_TOKEN
    * SLACK_CHANNELS
"""
import os
import sys

slack_envvars_defined = "SLACK_CHANNELS" in os.environ and "SLACK_TOKEN" in os.environ
if not slack_envvars_defined:
    print(
        "ERROR: Slack notifications require two environment variables: 'SLACK_CHANNELS' and 'SLACK_TOKEN'.",
        file=sys.stderr,
    )
    sys.exit(1)

S3_SRC = "s3://nextstrain-data/files/workflows/monkeypox"


rule notify_on_genbank_record_change:
    input:
        genbank_ndjson="data/genbank.ndjson",
    output:
        touch("data/notify/genbank-record-change.done"),
    params:
        s3_src=S3_SRC,
    shell:
        """
        ./bin/notify-on-record-change {input.genbank_ndjson} {params.s3_src:q}/genbank.ndjson.xz Genbank
        """


onstart:
    shell("./bin/notify-on-job-start")


onerror:
    shell("./bin/notify-on-job-fail")
