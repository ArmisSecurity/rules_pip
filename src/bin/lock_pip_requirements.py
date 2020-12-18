import argparse
import logging
import os
import sys
import textwrap

from piprules import localwheels, lockfile, pipcompat, requirements, resolve


LOG = logging.getLogger()


def main():
    args = parse_args()

    initialize_logging(args.verbosity)

    workspace_directory = get_workspace_directory()
    lock_file_path = os.path.join(workspace_directory, args.lock_file_path)
    wheel_directory = os.path.join(workspace_directory, args.wheel_dir)
    index_urls = args.index_urls or ["https://pypi.org/simple"]

    LOG.info("Locking pip requirements for Python %s", sys.version_info.major)

    pip_session = pipcompat.PipSession()

    lock_file = lockfile.load(lock_file_path or '')

    requirement_set = requirements.collect_and_condense(
        pip_session,
        lock_file,
        args.requirements_files,
        update_all=args.update_all,
        packages_to_update=args.packages_to_update,
    )

    resolved_requirements = resolve.resolve_requirement_set(
        requirement_set,
        pip_session,
        index_urls,
        wheel_directory,
    )

    lock_file.update_requirements_for_current_environment(resolved_requirements)

    new_local_wheels_package_label = "@{workspace}//{package}".format(
        workspace=args.workspace_name,
        package=args.wheel_dir,
    )
    if new_local_wheels_package_label != lock_file.local_wheels_package:
        LOG.warning(
            "Local wheels package is changing from '%s' to '%s'",
            lock_file.local_wheels_package,
            new_local_wheels_package_label,
        )
        lock_file.local_wheels_package = new_local_wheels_package_label

    if os.path.isdir(wheel_directory):
        local_wheels_package = localwheels.Package(wheel_directory)
        local_wheels_package.ensure_build_file_exists()
        local_wheels_package.purge_wheels(keep={
            source.file
            for source in lock_file.sources.values()
            if source.file
        })

    if lock_file_path:
        lock_file.dump(lock_file_path)
    else:
        print(lock_file.to_json())


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-l", "--lock-file",
        dest="lock_file_path",
    )
    parser.add_argument(
        "-U", "--update",
        action="store_true",
        dest="update_all",
    )
    parser.add_argument(
        "-P", "--update-package",
        action="append",
        dest="packages_to_update",
    )
    parser.add_argument(
        "-i", "--index-url",
        action="append",
        dest="index_urls",
    )
    parser.add_argument(
        "-w", "--wheel-dir",
        default="wheels",
    )
    parser.add_argument(
        "-W", "--workspace-name",
        required=True,
    )
    parser.add_argument(
        "-v", "--verbose",
        action="count",
        default=0,
        dest="verbosity",
        help="increase output verbosity"
    )
    parser.add_argument(
        "requirements_files",
        nargs="*",
    )
    return parser.parse_args()


def initialize_logging(verbosity):
    main_log_level = {
        0: logging.INFO,
        1: logging.INFO,
        2: logging.DEBUG,
    }.get(verbosity, logging.DEBUG)

    logging.basicConfig(
        level=main_log_level,
        format="%(message)s",
    )

    pip_log_level = {
        0: logging.WARNING,
        1: logging.INFO,
        2: logging.INFO,
        3: logging.DEBUG,
    }.get(verbosity, logging.DEBUG)

    pipcompat.LOG.setLevel(pip_log_level)

def get_workspace_directory():
    try:
        return os.environ["BUILD_WORKSPACE_DIRECTORY"]
    except KeyError:
        sys.exit("This tool must by executed via 'bazel run'")


if __name__ == "__main__":
    main()
