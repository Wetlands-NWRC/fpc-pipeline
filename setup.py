from setuptools import setup, find_packages

setup(
    name='fpc-code-runner',
    packages=(find_packages()),
    entry_points={
        'console_scripts' :[
            'code-runner = fpc.cli:cli'
        ]
    }
)
    