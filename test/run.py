#!/usr/bin/env python

"""Test that the toolchain can build executables.

Multiple build tools and languages are supported. If an emulator is available,
its ability to run the generated executables is also tested.
"""

import argparse
import glob
import os
import shutil
import subprocess
import sys
import tempfile

def test_none_build_system(build_dir, language, source, linker_flags, exe_suffix):
    build_cmd = list()
    if language == 'C':
        compiler = os.getenv('CC', 'cc')
    elif language == 'C++':
        compiler = os.getenv('CXX', 'c++')
    else:
        print('Unknown language: ' + language)
        return 1
    build_cmd.append(compiler)
    if linker_flags:
        build_cmd.extend(linker_flags)
    build_cmd.append(source)

    build_cmd.append('-o')
    build_cmd.append('a.out' + exe_suffix)

    print('Building ' + source + ' by calling ' + compiler + '...')
    print(' '.join(build_cmd))
    sys.stdout.flush()

    return subprocess.call(build_cmd)


def test_cmake_build_system(build_dir, language, source, emulator, linker_flags,
        exe_suffix):
    shutil.copy(source, build_dir)
    print('Building ' + source + ' with CMake...')

    with open('CMakeLists.txt', 'w') as fp:
        fp.write('cmake_minimum_required(VERSION 3.4)\n')
        fp.write('project(test-compiler)\n')
        fp.write('add_executable(a.out ' + os.path.basename(source) + ')\n')
        if emulator:
            fp.write('enable_testing()\n')
            fp.write('add_test(NAME emulator-in-cmake COMMAND a.out)\n')

    os.mkdir('build')
    os.chdir('build')

    cmake_configuration_cmd = ['cmake', '..']
    if linker_flags:
        cmake_configuration_cmd.insert(1,
                '-DCMAKE_EXE_LINKER_FLAGS="{0}"'.format(' '.join(linker_flags)))
    print(' '.join(cmake_configuration_cmd))
    sys.stdout.flush()
    if subprocess.call(cmake_configuration_cmd):
        return 1
    if subprocess.call(['make', 'VERBOSE=1']):
        return 1
    if emulator:
        if subprocess.call(['ctest']):
            return 1
    shutil.copy('a.out' + exe_suffix, build_dir)
    return 0


def test_source(source, language, build_system, emulator, linker_flags,
        exe_suffix, debug):
    result = 0
    cwd = os.getcwd()
    build_dir = tempfile.mkdtemp()
    os.chdir(build_dir)

    if build_system == 'None':
        result += test_none_build_system(build_dir, language, source,
                linker_flags, exe_suffix)
    elif build_system == 'CMake':
        result += test_cmake_build_system(build_dir, language, source, emulator,
                linker_flags, exe_suffix)
    else:
        print('Unknown build system: ' + build_system)
        result += 1

    if emulator:
        cmd = emulator
        cmd += ' ' + os.path.join(build_dir, 'a.out' + exe_suffix)
        print('Running ' + cmd + '...')
        sys.stdout.flush()
        result += subprocess.call(cmd, shell=True)

    os.chdir(cwd)
    if not debug:
        print('Deleting temporary build directory ' + build_dir)
        shutil.rmtree(build_dir)
    else:
        print('Keeping temporary build directory ' + build_dir)

    sys.stdout.flush()
    return result


def test_build_system(test_dir, language, build_system, emulator, linker_flags,
        exe_suffix, debug):
    print('\n\n--------------------------------------------------------')
    print('Testing ' + build_system + ' build system with the ' +
          language + ' language\n')
    sys.stdout.flush()
    result = 0
    for source in glob.glob(os.path.join(test_dir, language, '*')):
        result += test_source(source, language, build_system, emulator,
                linker_flags, exe_suffix, debug)
    return result


def test_language(test_dir, language, build_systems, emulator, linker_flags,
        exe_suffix, debug):
    result = 0
    for build_system in build_systems:
        result += test_build_system(test_dir,
                language,
                build_system,
                emulator,
                linker_flags,
                exe_suffix,
                debug)
    return result


def run_tests(test_dir, languages=('C', 'C++'), build_systems=('None', 'CMake'),
        emulator=None, linker_flags=None, exe_suffix='', debug=False):
    """Run the tests found in test_dir where each directory corresponds to an
    entry in languages. Every source within a language directory is built. The
    output executable is also run with the emulator if provided."""
    result = 0
    for language in languages:
        result += test_language(test_dir,
                language,
                build_systems,
                emulator,
                linker_flags,
                exe_suffix,
                debug)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
            description='Test the cross-compiler toolchain.')
    parser.add_argument('--languages', '-l', nargs='+', default=['C', 'C++'],
            help='Languages to test. Options: C C++')
    parser.add_argument('--build-systems', '-b', nargs='+', default=['None', 'CMake'],
            help='Build systems to test. Options: None CMake')
    parser.add_argument('--emulator', '-e',
            help='Emulator used to test generated executables')
    parser.add_argument('--linker-flags', '-w', nargs='+',
            help='Extra compilation linker flags')
    parser.add_argument('--exe-suffix', '-s', default='',
            help='Suffix for generated executables')
    parser.add_argument('--debug', '-d', action='store_true',
            help='Do not remove temporary build directory')
    args = parser.parse_args()

    test_dir = os.path.dirname(os.path.abspath(__file__))

    sys.exit(run_tests(test_dir,
        languages=args.languages,
        build_systems=args.build_systems,
        emulator=args.emulator,
        linker_flags=args.linker_flags,
        exe_suffix=args.exe_suffix,
        debug=args.debug) != 0)
