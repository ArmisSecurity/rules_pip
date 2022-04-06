load("//rules:wheel.bzl", "remote_wheel")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def pip_rules_dependencies():
    _remote_wheel(
        name = "pip",
        url = "https://files.pythonhosted.org/packages/54/eb/4a3642e971f404d69d4f6fa3885559d67562801b99d7592487f1ecc4e017/pip-20.3.3-py2.py3-none-any.whl",
        sha256 = "fab098c8a1758295dd9f57413c199f23571e8fde6cc39c22c78c961b4ac6286d",
    )

    _remote_wheel(
        name = "schematics",
        url = "https://files.pythonhosted.org/packages/97/2f/2c5f0dc4dab5e5ca54e4d783f7f618bfc65d8788771876713d42eb8515aa/schematics-2.1.0-py2.py3-none-any.whl",
        sha256 = "8fcc6182606fd0b24410a1dbb066d9bbddbe8da9c9509f47b743495706239283",
    )

    _remote_wheel(
        name = "setuptools",
        url = "https://files.pythonhosted.org/packages/0e/8e/4d9a9009afeae48ec1301713d96b9ae901aa6e157637ddf37e844c1bf4ee/setuptools-45.3.0-py3-none-any.whl",
        sha256 = "c12bf030a5f5cad222d98ee0a0c10d76b4bcaf45e23501e5480c4b6f9c3f643f",
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
