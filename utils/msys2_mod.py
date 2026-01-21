import pathlib
import sys

root = pathlib.Path(__file__).parent


def add_path_env(content, pathes):
    pth = []
    pth.append(r'C:\Windows')
    pth.append(r'C:\Windows\System32')
    for path in pathes:
        pth.append(path)

    pth = [p for p in pth if p.strip()]
    c = f'set PATH={";".join(pth)}'
    old = content.splitlines()
    new = old[:-1] + [c] + old[-1:]
    return "\n".join(new)


def add_path_qt(content, qt_install_prefix):
    old = content.splitlines()
    new = old[:-1] + [f'set QT_ROOT={qt_install_prefix}'] + old[-1:]
    return "\n".join(new)


def winpath_2_msyspath(path):
    if not path:
        return path
    path = pathlib.Path(path).as_posix()
    path = '/' + "".join(path.split(':'))
    return path


def modify_msys_cmd_file(pathes, qt_install_prefix, msys_cmd_file=r'D:\a\_temp\setup-msys2\msys2.CMD'):
    # print(pathes)
    msys_cmd_file = pathlib.Path(msys_cmd_file)

    if not msys_cmd_file.exists():
        print(f' >  {msys_cmd_file} not exists')
        return

    # 修改配置文件，使MSYS2使用系统环境变量
    content = msys_cmd_file.open('r', encoding='utf-8').read().replace('minimal', "inherit").strip()

    content = add_path_env(content, pathes)

    qt_install_prefix = winpath_2_msyspath(qt_install_prefix)
    content = add_path_qt(content, qt_install_prefix)

    with msys_cmd_file.open('w', encoding='utf-8') as f:
        f.write(content)
    print('-----------------------------msys2 start script start--------------------------')
    for line in content.splitlines():
        print(f'  > {line}')
    print('----------------------------- msys2 start script end --------------------------')


modify_msys_cmd_file(qt_install_prefix=sys.argv[1], pathes=sys.argv[2:])
