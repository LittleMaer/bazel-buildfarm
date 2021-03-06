"""
buildfarm dependencies that can be imported into other WORKSPACE files
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

RULES_JVM_EXTERNAL_TAG = "3.0"
RULES_JVM_EXTERNAL_SHA = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a"

def archive_dependencies(third_party):
    return [
        {
            "name": "rules_jvm_external",
            "strip_prefix": "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
            "sha256": RULES_JVM_EXTERNAL_SHA,
            "url": "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
        },

        # Needed for "well-known protos" and @com_google_protobuf//:protoc.
        {
            "name": "com_google_protobuf",
            "sha256": "b37e96e81842af659605908a421960a5dc809acbc888f6b947bc320f8628e5b1",
            "strip_prefix": "protobuf-3.12.0",
            "urls": ["https://github.com/protocolbuffers/protobuf/archive/v3.12.0.zip"],
        },

        # Needed for @grpc_java//compiler:grpc_java_plugin.
        {
            "name": "io_grpc_grpc_java",
            "patch_args": ["-p1"],
            "sha256": "849780c41b7a251807872a00b752cc965da483e0c345b25f78ed163e878b9b2c",
            "strip_prefix": "grpc-java-1.30.2",
            "urls": ["https://github.com/grpc/grpc-java/archive/v1.30.2.zip"],
        },

        # The APIs that we implement.
        {
            "name": "googleapis",
            "build_file": "%s:BUILD.googleapis" % third_party,
            "sha256": "7b6ea252f0b8fb5cd722f45feb83e115b689909bbb6a393a873b6cbad4ceae1d",
            "strip_prefix": "googleapis-143084a2624b6591ee1f9d23e7f5241856642f4d",
            "url": "https://github.com/googleapis/googleapis/archive/143084a2624b6591ee1f9d23e7f5241856642f4d.zip",
        },

        {
            "name": "remote_apis",
            "build_file": "%s:BUILD.remote_apis" % third_party,
            "patch_args": ["-p1"],
            "patches": ["%s/remote-apis:remote-apis.patch" % third_party],
            "sha256": "21ad15be502ef529ca07fdda56d25d6678647b954d41f08a040241ea5e43dce1",
            "strip_prefix": "remote-apis-b5123b1bb2853393c7b9aa43236db924d7e32d61",
            "url": "https://github.com/bazelbuild/remote-apis/archive/b5123b1bb2853393c7b9aa43236db924d7e32d61.zip",
        },

        # Download the rules_docker repository at release v0.14.1
        {
            "name": "io_bazel_rules_docker",
            "patch_args": ["-p1"],
            "patches": [
                "%s/rules_docker:rules_docker.patch" % third_party,
            ],
            "sha256": "dc97fccceacd4c6be14e800b2a00693d5e8d07f69ee187babfd04a80a9f8e250",
            "strip_prefix": "rules_docker-0.14.1",
            "urls": ["https://github.com/bazelbuild/rules_docker/archive/v0.14.1.tar.gz"],
        },
    ]

def buildfarm_dependencies(repository_name="build_buildfarm"):
    """
    Define all 3rd party archive rules for buildfarm
    
    Args:
      repository_name: the name of the repository
    """
    third_party = "@%s//third_party" % repository_name
    for dependency in archive_dependencies(third_party):
        params = {}
        params.update(**dependency)
        name = params.pop("name")
        maybe(http_archive, name, **params)

    maybe(
        http_jar,
        "jedis",
        sha256 = "934c416359965d5b17a8703e66c8fa221037ddf40f29caa25d2f59525ac4c32e",
        urls = [
            "https://github.com/werkt/jedis/releases/download/jedis-3.2.0-d34c20f0d2/jedis-3.2.0-d34c20f0d2.jar",
        ])
