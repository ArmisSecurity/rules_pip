load("//rules:wheel.bzl", "remote_wheel")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def pip_rules_dependencies():
    _remote_wheel(
        name = "pip",
        url = "https://files.pythonhosted.org/packages/ca/31/b88ef447d595963c01060998cb329251648acf4a067721b0452c45527eb8/pip-21.2.4-py3-none-any.whl",
        sha256 = "fa9ebb85d3fd607617c0c44aca302b1b45d87f9c2a1649b46c26167ca4296323",
    )

    _remote_wheel(
        name = "schematics",
        url = "https://files.pythonhosted.org/packages/97/2f/2c5f0dc4dab5e5ca54e4d783f7f618bfc65d8788771876713d42eb8515aa/schematics-2.1.0-py2.py3-none-any.whl",
        sha256 = "8fcc6182606fd0b24410a1dbb066d9bbddbe8da9c9509f47b743495706239283",
    )

    _remote_wheel(
        name = "setuptools",
        url = "https://files.pythonhosted.org/packages/75/b3/0a106dfaf7f48aef638da80b32608617cc8de4b24a22c8cd3759c32e5d30/setuptools-41.1.0-py2.py3-none-any.whl",
        sha256 = "bce3560fae29e9efa45fdb6e9fceddb1cde0cccebb050ee134262283b3ccbc7b",
    )

    _remote_wheel(
        name = "wheel",
        url = "https://files.pythonhosted.org/packages/fc/e9/05316a1eec70c2bfc1c823a259546475bd7636ba6d27ec80575da523bc34/wheel-0.32.1-py2.py3-none-any.whl",
        sha256 = "9fa1f772f1a2df2bd00ddb4fa57e1cc349301e1facb98fbe62329803a9ff1196",
    )

    _ensure_rule_exists(
        git_repository,
        name = "bazel_skylib",
        remote = "https://github.com/bazelbuild/bazel-skylib.git",
        tag = "0.5.0",
    )

def _remote_wheel(name, url, sha256):
    _ensure_rule_exists(
        remote_wheel,
        name = "pip_rules__%s" % name,
        url = url,
        sha256 = sha256,
    )

def _ensure_rule_exists(rule_type, name, **kwargs):
    if name not in native.existing_rules():
        rule_type(name = name, **kwargs)
