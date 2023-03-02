import os
import glob
import rasterio

from rasterio.merge import merge
from osgeo import gdal
from typing import Dict, List

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(CURRENT_DIR)


def get_tif_paths(dirpath: str) -> List[str]:
    ext = '*.tif'
    q = os.path.join(dirpath, ext)
    tifs = glob.glob(q)
    return tifs


def get_rowidx(paths) -> set:
    rowidxs = []
    for path in paths:
        basename = path.split('/')[-1]
        rowidx = basename.split("-")[3]
        rowidxs.append(rowidx)
    return set(rowidxs)


def sort_by_row(idxs: set, paths:List[str]) -> Dict[str, List[str]]:
    container = {_ : [] for _ in idxs}
    for path in paths:
        for idx in idxs:
            path_idx = path.split("/")[-1].split("-")[3]
            if idx == path_idx:
                container.get(idx).append(path)
    return container


def build_rows(tiffs: Dict[str, List[str]], dest: str = None):

    tmp_dest = "./tmp-row" if dest is None else dest

    if not os.path.exists(tmp_dest):
        os.makedirs(tmp_dest)
    
    for rowidx, paths in tiffs.items():
        print(f"Building: {rowidx}")

        to_mosaic = []
        for path in paths:
            src = rasterio.open(path)
            to_mosaic.append(src)

        mosaic, out_trans = merge(to_mosaic)

        out_meta = src.meta.copy()

        out_meta.update({"driver": "GTiff",
                    "height": mosaic.shape[1],
                    "width": mosaic.shape[2],
                    "transform": out_trans,
                    "crs": "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
                    })
        out_fp = f'{tmp_dest}/scores-{rowidx}.tif'
        with rasterio.open(out_fp, 'w', **out_meta) as dest:
            dest.write(mosaic)
            dest.close()
        
        _ = [tif.close() for tif in to_mosaic]
        to_mosaic = None


def build_mosaic(tiffs: List[str], out_name:str):
    to_mosaic = []
    for fp in tiffs:
        src = rasterio.open(fp)
        to_mosaic.append(src)

    mosaic, out_trans = merge(to_mosaic)

    out_meta = src.meta.copy()

    out_meta.update({"driver": "GTiff",
                 "height": mosaic.shape[1],
                 "width": mosaic.shape[2],
                 "transform": out_trans,
                 "crs": "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
                 })
    out_fp = f"./{out_name}.tif"
    with rasterio.open(out_fp, 'w', **out_meta) as dest:
        dest.write(mosaic)
        dest.close()
    
    _ = [tif.close() for tif in to_mosaic]
    to_mosaic = None

def main(args: list = None):
    dirpath = './tiffs-scores'
    out_fp = './VV-2020-MASTER.tif'
    search_crietera = '*.tif'
    q = os.path.join(dirpath, search_crietera)
    tifs = glob.glob(q)

    rowindex = get_rowidx(tifs)
    idx_container = sort_by_row(rowindex, tifs)

    build_rows(idx_container)

    row_tifs = get_tif_paths("./tmp-row")
    build_mosaic(row_tifs, 'VH-2018-MASTER')
    p = ' '

if __name__ == '__main__':
    main()