import os
import subprocess

from typing import List

class _CodeRunner:
    """Base Class for Fpc Pipeline"""
    
    CURRENT_DIR = os.path.abspath(os.path.dirname(__file__))
    CODE_DIR = os.path.join(CURRENT_DIR, '..', 'code')
    R_EXE = 'Rscript'
    
    def __init__(self, data_dir: str, code_dir: str = None, output_dir: str = None,
                 target_var: str = None, target_land_covers: str = None) -> None:
        """
        R SCRIPT Command Mappings
        data.directory    = data_dir
        code.directory    = code_dir
        output.directory  = output_dir
        target.variable   = target_var
        target.landcovers = target_land_covers
        
        """
        self.data_dir = data_dir
        self.code_dir = self.CODE_DIR if code_dir is None else code_dir
        self.out_dir = "." if output_dir is None else output_dir
        self.target_var = target_var
        self.target_land_covers = target_land_covers
        
        self.entry_point = 'cli.R'        
        self.target_var = 'VV' if self.target_var is None else self.target_var
    
    @property
    def cmd(self):
        args = [item for item in self.__dict__ if item is not None]
        return [self.R_EXE, *args]
    
    def run(self) -> int:
        with open(f"{self.out_dir}/stdout.txt", "wb") as out, open(f"{self.out_dir}/stderr.txt", "wb") as err:
            process = subprocess.Popen(self.cmd, stderr=err, stdout=out)
            process.communicate()
            process.kill()
            exit = process.wait()
        return exit


class RunDiagCli(_CodeRunner):
    def __init__(self, data_dir: str, code_dir: str = None, output_dir: str = None, 
                 target_var: str = None, target_land_covers: str = None) -> None:
        super().__init__(data_dir, code_dir, output_dir, target_var, target_land_covers)
        self.entry_point = 'diag-cli.R'