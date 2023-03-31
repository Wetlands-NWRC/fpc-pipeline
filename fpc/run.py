import os
import subprocess

from typing import List

class _CodeRunner:
    """Base Class for Fpc Pipeline"""
    
    CURRENT_DIR = os.path.abspath(os.path.dirname(__file__))
    CODE_DIR = os.path.join(CURRENT_DIR, '..', 'code')
    R_EXE = 'R'
    
    def __init__(self, data_dir: str, out_dir: str, target_var: str = None, target_land_cover: str = None) -> None:
        self.data_dir = data_dir
        self.target_var = target_var
        self.target_lc = target_land_cover
        self.entry_point = 'cli.R'
        self.out_directory = out_dir
        
        self.target_var = 'VV' if self.target_var is None else self.target_var
    
    @property
    def cmd(self):
        return [self.R_EXE, "--no-save --args", self.data_dir, self.CODE_DIR, self.out_directory,
         self.target_var, self.target_lc, "<", self.entry_point]
    
    def run(self) -> int:
        with open(f"{self.out_dir}/stdout.txt", "wb") as out, open(f"{self.out_dir}/stderr.txt", "wb") as err:
            process = subprocess.Popen(self.cmd, stderr=err, stdout=out)
            process.communicate()
            process.kill()
            exit = process.wait()
        return exit


class RunMain(_CodeRunner):
    def __init__(self, data_dir: str, out_dir: str, target_var: str = None, target_land_cover: str = None) -> None:
        super().__init__(data_dir, out_dir, target_var, target_land_cover)


class RunDiagnostics(_CodeRunner):
    def __init__(self, data_dir: str, out_dir: str, target_var: str = None, target_land_cover: str = None) -> None:
        super().__init__(data_dir, out_dir, target_var, target_land_cover)
        self.entry_point = 'diagnostics.R'
 