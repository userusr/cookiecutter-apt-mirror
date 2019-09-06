import re
from contextlib import contextmanager
from cookiecutter.utils import rmtree


@contextmanager
def bake_in_temp_dir(cookies, *args, **kwargs):
    """
    Delete the temporal directory that is created when executing the tests
    :param cookies: pytest_cookies.Cookies,
        cookie to be baked and its temporal files will be removed
    """
    result = cookies.bake(*args, **kwargs)
    try:
        yield result
    finally:
        rmtree(str(result.project))


def test_bake_with_defaults(cookies):
    with bake_in_temp_dir(cookies) as result:
        assert result.project.isdir()
        assert result.exit_code == 0
        assert result.exception is None

        found_toplevel_files = [f.basename for f in result.project.listdir()]
        assert "Makefile" in found_toplevel_files
        assert "etc" in found_toplevel_files
        assert "mirror" in found_toplevel_files
        assert "skel" in found_toplevel_files
        assert "var" in found_toplevel_files


def test_project_dir_is_apt_mirror_base_dir(cookies):
    with bake_in_temp_dir(cookies) as result:
        project_path = str(result.project)
        re_base_path = ''.join([r'set\s+base_path\s+', project_path, r'\n'])
        apt_mirror_conf_file_path = result.project.join("etc/mirror.list")
        pattern = re.compile(re_base_path)
        assert pattern.search(apt_mirror_conf_file_path.read()) is not None
