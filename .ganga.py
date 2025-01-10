'''
File used to define code that needs to be ran before ganga starts
'''
# pylint: disable=line-too-long, wrong-import-position, import-error

import sys
import os
import re
import glob
import json
from dataclasses import dataclass
from typing      import Union

sys.path.append('/home/acampove/micromamba/envs/post_ap/lib/python3.11/site-packages')

import tqdm
from dmu.logging.log_store import LogStore

from GangaCore.GPI                             import DiracFile
from GangaCore.GPIDev.Lib.Registry.JobRegistry import JobRegistrySliceProxy as JRSP

log = LogStore.add_logger('_ganga_py', exists_ok=True)
# ----------------------------------
@dataclass
class Data:
    '''
    Class used to share data between functions
    '''

    d_grid_slc : dict
    d_grid_sta : dict
    jbm        : JRSP
    gan_dir    : str
    rx_path    : str
# ----------------------------------
def _load_slices(force=False):
    for jsonpath in glob.glob('Data.gan_dir/*.json'):
        jsonname=os.path.basename(jsonpath)
        slcname=jsonname.replace('.json', '')

        if force is False and slcname in Data.d_grid_slc:
            continue

        with open(jsonpath, encoding='utf-8') as ifile:
            l_job=json.load(ifile)

        Data.d_grid_slc[slcname] = l_job
# ----------------------------------
def monitor(identifier) -> JRSP:
    '''
    Function taking a slice name (str) or a job number (int)
    and running monitoring loop for it
    '''
    if   isinstance(identifier, str):
        sl_job= _get_slice(identifier)
    elif isinstance(identifier, int):
        sl_job=Data.jbm.select(identifier, identifier)
    else:
        raise ValueError(f'Argument not a slice name or job ID: {identifier}')

    runMonitoring(sl_job)

    return sl_job
# ----------------------------------
# ----------------------------------
def write_lfns(arg : Union[int,str,JRSP], version : Union[str,None]):
    '''
    Will take:

    l_job:   A list of jobs, name of a slice, or the index of a job
    version: If passed, the files with the LFNs will be sent to $LFN_PATH/data/LFNs/{version}

    Will write a file with list of PFNs or LFNs
    '''
    l_job = _jobs_from_arg(arg)
    if l_job is None:
        return

    d_xfn={}
    for job in l_job:
        jobid= _id_from_job(job)
        log.info(f'Job: {jobid:05}')

        l_sj = job.subjobs
        if len(l_sj) == 0:
            l_sj = [job]

        d_xfn[jobid] = _xfns_from_subjobs(l_sj, 'lfn', job)

    _save_xfns(d_xfn, 'lfn', version)
# ----------------------------------
def _jobs_from_arg(arg : Union[int, str, JRSP]) -> Union[JRSP,None]:
    if isinstance(arg, str):
        return _get_slice(arg)

    if isinstance(arg, JRSP):
        return arg

    if isinstance(arg, int):
        return Data.jbm.select(arg, arg)

    log.warning(f'Cannot return job slice from argument: {arg}')

    return None
# ----------------------------------
def _get_slice(name : str) -> Union[JRSP,None]:
    '''
    Will take the slice name and return slice if found, or None otherwise
    '''
    _load_slices()

    if name not in Data.d_grid_slc:
        log.warning(f'Cannot find job {name}')
        _show_slices()
        return None

    l_job_id = Data.d_grid_slc[name]

    slc = Data.jbm.select(l_job_id)

    return slc
# ----------------------------------
def _show_slices(load_statistics : bool = False) -> None:
    _load_slices()

    for slcname in sorted(Data.d_grid_slc.items()):
        if not load_statistics:
            log.info(slcname)
            continue
# ----------------------------------
def _id_from_job(job) -> int:
    regex= r'(\d+)\.\d+\.\d'

    mtch=re.match(regex, job.name)
    if mtch:
        job_id = int(mtch.group(1))
    else:
        job_id = job.id

    return job_id
# ----------------------------------
def _xfns_from_subjobs(l_sj : list, kind : str, job : JRSP) -> list[str]:
    l_xfn = []
    for sj in tqdm.tqdm(l_sj, ascii=' -'):
        l_file = _files_from_subjob(sj)
        if l_file is None:
            continue

        for df in l_file:
            l_df_xfn = _xfns_from_file(df, kind)
            if l_df_xfn is None:
                continue

            l_xfn += _clean_xfns(l_df_xfn, kind, job.id, sj.id)

    return l_xfn
# ----------------------------------
def _files_from_subjob(sj) -> Union[None,list[DiracFile]]:
    if sj.status != 'completed':
        log.debug(f'Skipping: {sj.id}/{sj.status}')
        return None

    l_file=sj.outputfiles.get(DiracFile)
    if len(l_file) == 0:
        log.warning(f'No files found for subjob {sj.id}')
        return None

    return l_file
# ----------------------------------
def _clean_xfns(l_xfn : list[str], kind : str, jid : int, sid : int) -> list[str]:
    l_xfn_clean = []
    for xfn in l_xfn:
        xfn=xfn.replace(' ', '')

        if xfn == '':
            log.warning(f'Cannot find {kind} for {jid}.{sid}')
            continue

        l_xfn_clean.append(xfn)

    return l_xfn_clean
# ----------------------------------
def _xfns_from_file(df : DiracFile, kind : str) -> Union[list,None]:
    if   kind == 'lfn':
        l_xfn=[df.lfn]

        return l_xfn

    if kind == 'pfn':
        try:
            l_xfn=df.accessURL()

            return l_xfn
        except Exception:
            print(f'Cannot retrieve URL for: {df.lfn}')

    return None
# ----------------------------------
def _save_xfns(d_xfn : dict[str,list[str]], kind : str, version : Union[str,None]) -> None:
    for jobid, l_xfn in d_xfn.items():
        file_path = _path_from_version(jobid, version, kind)

        log.info(f'Sending xFNs to: {file_path}')
        if len(l_xfn) == 0:
            log.warning(f'Could not find {kind}s for job {jobid}')
            continue

        with open(file_path, 'w', encoding='utf-8') as ofile:
            json.dump(l_xfn, ofile, indent=4)
# ----------------------------------
def _path_from_version(jobid : str, version : Union[str,None], kind : str) -> str:
    file_name = f'{kind}_{jobid:03}.json'
    if version is None:
        return f'./{file_name}'

    file_dir  = f'{Data.rx_path}/src/rx_data_lfns/{version}'
    file_path = f'{file_dir}/{file_name}'
    if os.path.isfile(file_path):
        raise ValueError(f'Directory {file_dir} already found, version {version} might be wrong')

    os.makedirs(file_dir, exist_ok=True)

    return file_path
# ----------------------------------
# ----------------------------------
def _get_env_var(name : str) -> str:
    if name not in os.environ:
        log.warning(f'Cannot find {name} in environment')
    else:
        name = os.environ[name]

    return name
# ----------------------------------
def _initialize():
    Data.gan_dir = _get_env_var('GANDBS')
    sft_dir      = _get_env_var('SFTDIR')
    Data.rx_path = f'{sft_dir}/rx_data'
    Data.jbm     = jobs
# ----------------------------------
_initialize()
