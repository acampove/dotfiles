import time
import pickle
import json
import glob
import os
import re
import sys

from datetime import datetime

sys.path.append('/cvmfs/lhcb.cern.ch/lib/var/lib/LbEnv/2683/stable/linux-64/lib/python39.zip')
sys.path.append('/cvmfs/lhcb.cern.ch/lib/var/lib/LbEnv/2683/stable/linux-64/lib/python3.9')
sys.path.append('/cvmfs/lhcb.cern.ch/lib/var/lib/LbEnv/2683/stable/linux-64/lib/python3.9/lib-dynload')
sys.path.append('/afs/ihep.ac.cn/users/c/campoverde/.local/lib/python3.9/site-packages')
sys.path.append('/publicfs/ucas/user/campoverde/Packages/decaylanguage/src')
sys.path.append('/cvmfs/lhcb.cern.ch/lib/var/lib/LbEnv/2683/stable/linux-64/lib/python3.9/site-packages')

#import utils_noroot as utnr
import pandas       as pnd

from IPython.display import display
from tqdm            import tqdm

do_monitor=True
d_env=os.environ
if "GANDIR" not in d_env:
    print("GANDIR not an environment variable, needs to be specified in .bashrc")
    exit(1)

GANDIR=d_env['GANDIR']
d_grid_slc={}
d_grid_sta={}

#------------------------------
def search_jobs(regex=None, slc=None, id_min=None):
    """
    Will print information on jobs that match given regex

    Parameters
    ---------------
    regex (str): Regular expression meant to match job names.
    slc (slice): Ganga slice object where the search will happen, if None, will use all jobs.
    id_min (int): Search only jobs above this job ID. If none, search all jobs
    """

    if slc is None:
        slc = jobs

    print('-' * 30)
    print(f'{"Name":<30}{"ID":<20}{"Succeeded":<10}{"Failed":<10}{"Finalized":<20}')
    print('-' * 30)
    for job in slc:
        if id_min is not None and job.id < id_min:
            continue

        name = job.name
        mtch = re.match(regex, name)
        if not mtch:
            continue

        nsuc = 0
        nfal = 0
        for sj in job.subjobs:
            if sj.status == 'completed':
                nsuc += 1
            else:
                nfal += 1

        time_str = job.time.final(format='%Y/%m/%d %H:%M:%S')

        print(f'{name:<30}{job.id:<20}{nsuc:<10}{nfal:<10}{time_str:<20}')
#------------------------------
def get_job_info(event_type, job_name):
    if job_name.startswith('ana_ntup'):
        return '.', job_name 

    if event_type != 'data' and event_type not in job_name:
        return

    if event_type == 'data':
        regex =             f'(\d{{4}})_(MagUp|MagDown)'
    else:
        regex =f'{event_type}_(\d{{4}})_(MagUp|MagDown)'

    mtch = re.match(regex, job_name)
    if not mtch and event_type == 'data':
        return

    if not mtch:
        print(f'Cannot match \"{job_name}\" with {regex}')
        raise

    year   = mtch.group(1)
    pola   = mtch.group(2)

    return year, pola
#------------------------------
def dump_stats(event_type, update=False, stored=True):
    out_path = f'{GANDIR}/job_stats/{event_type}.json'
    if os.path.isfile(out_path) and not update:
        return pnd.read_json(out_path)

    os.makedirs(f'{GANDIR}/job_stats/', exist_ok=True)

    df = pnd.DataFrame(columns=['Job', 'Year', 'Polarity', 'Files', 'Events', 'Dates'])

    event_type = str(event_type)
    for job in jobs:
        t_job_info = get_job_info(event_type, job.name)
        if t_job_info is None:
            continue 

        year, pola = t_job_info
        jobid      = job.id
        files      = len(job.subjobs)

        print(f'Processing {job.name}')
        nev, _, l_date = get_log_events(job, stored = stored)
        s_date     = set(l_date)
        dates      = ';'.join(s_date)

        df.loc[-1] = [jobid, year, pola, files, nev, dates]
        df.index   = df.index + 1
        df         = df.sort_index()

    df.to_json(out_path, indent=4)

    return df
#------------------------------
def get_lfns(job):
    l_out_file = job.outputfiles

    l_lfn = []
    for out_file in l_out_file:
        try:
            lfn = out_file.lfn
        except:
            lfn = 'not-found'

        l_lfn.append(lfn)

    return l_lfn
#------------------------------
def get_stat(job):
    l_sjob = job.subjobs
    njobs  = len(l_sjob)
    name   = job.name
    status = job.status
    site   = job.backend.actualCE

    d_sjob_lfns = { sjob.id : get_lfns(sjob) for sjob in l_sjob}

    d_stat = {}
    d_stat['njobs' ] = njobs
    d_stat['name'  ] = name 
    d_stat['status'] = status 
    d_stat['site'  ] = site 
    d_stat['lfns'  ] = d_sjob_lfns 

    return d_stat
#------------------------------
def save_stats():
    d_stat    = {job.id: get_stat(job) for job in tqdm(jobs, ascii=' -')}
    stat_path = f'{GANDIR}/job_stats.json'

    print(f'Saving: {stat_path}')
    utnr.dump_json(d_stat, stat_path)
#------------------------------
#Re-split
#------------------------------
def resplit_slice(name):
    if   type(name) == str:
        load_slices()
        if name not in d_grid_slc:
            print("Cannot find slice " + name)
            return
        l_job =d_grid_slc[name]


        slc=jobs.select(l_job_id)
    elif type(name) == int:
        slc=jobs.select(name, name)
    else:
        slc=name


    slc_resplit=None
    for job in slc:
        if len(job.subjobs) == 0:
            l_sj = [job]

        for sj in l_sj: 
            if sj.status == 'failed':
                if slc_resplit is None:
                    slc_resplit = resplit_subjob(job.id, sj)
                else:
                    slc_new = resplit_subjob(job.id, sj)
                    slc_resplit = add_slices(slc_resplit, slc_new)
                #sj.remove()

    return slc_resplit 
#------------------------------
def resplit_subjob(jobid, subjob):
    l_file=subjob.inputdata.files

    if type(l_file[0]) == LHCbCompressedFileSet:
        l_file=getDataFromFileSet(l_file[0])

    sjid=subjob.id
    oldCE=subjob.backend.actualCE

    backend=Dirac()
    if oldCE is None:
        print("No CE found for subjob {}.{}, not blacklisting".format(jobid, sjid))
    else:
        print("resplit_subjob::Blacklisting old CE " + oldCE)
        backend.settings['BannedSites'] = [oldCE]

    l_jobid=[]
    for cid, FILE in enumerate(l_file):
        j           = subjob.copy()
        j.inputdata = [FILE]
        j.backend   = backend
        new_name    = "{}.{}.{}".format(jobid, sjid, cid)
        j.name      = new_name 
        l_jobid.append(j.id)
        print("resplit_subjob::Creating " + new_name)

    return jobs.select(l_jobid)
#------------------------------
def getDataFromFileSet(fileset):
    l_lfn=fileset.getLFNs()
    l_file=[]
    for lfn in l_lfn:
        FILE=DiracFile()
        FILE.lfn=lfn
        l_file.append(FILE)

    return l_file
#------------------------------
#Slice operations
#------------------------------
def add_slices(slc_1, slc_2):
    l_job_id_1=[]
    l_job_id_2=[]

    for job in slc_1:
        l_job_id_1.append(job.id)

    for job in slc_2:
        l_job_id_2.append(job.id)

    return jobs.select(l_job_id_1 + l_job_id_2)
#------------------------------
#Job storage
#------------------------------
def load_slices(force=False):
    for jsonpath in glob.glob(GANDIR + "/*.json"):
        jsonname=os.path.basename(jsonpath)
        slcname=jsonname.replace(".json", "")

        if force == False and slcname in d_grid_slc:
            continue

        l_job=json.load(open(jsonpath))

        d_grid_slc[slcname] = l_job
#------------------------------
def show_slices(load_statistics=False):
    load_slices()

    for slcname, l_job in sorted(d_grid_slc.items()):
        if not load_statistics:
            print("{0:30}".format(slcname) )
            continue

        if slcname not in d_grid_sta:
            d_grid_sta[slcname]={}
            d_slice=d_grid_sta[slcname]
            for job_id in tqdm(l_job_id):
                job=jobs(job_id)
                d_tmp = getJobStatus(job)
                for stat, freq in d_tmp.items():
                    if stat not in d_slice:
                        d_slice[stat] = freq 
                    else:
                        d_slice[stat]+= freq

        print("{0:30}{1:50}".format(slcname, str(d_grid_sta[slcname])))
#------------------------------
def getJobStatus(job):
    if len(job.subjobs) == 0:
        return {job.status : 1} 

    d_status={}
    for sj in job.subjobs:
        status = sj.status
        #if status == "failed":
        #    print("{}.{}".format(job.id, sj.id))

        if status not in d_status:
            d_status[status] = 1
        else:
            d_status[status]+= 1

    return d_status
#------------------------------
def get_slice(name):
    load_slices()

    if name not in d_grid_slc:
        print("Cannot find job " + name)
        show_slices()
        return

    l_job_id = d_grid_slc[name]

    return jobs.select(l_job_id)
#------------------------------
def save_slice(slc, name, force=False):
    jsonpath="{}/{}.json".format(GANDIR, name)

    if force == False and os.path.isfile(jsonpath):
        print("Job with name {} already exists".format(name))
        return

    l_job_id=[job.id for job in slc]

    json.dump(l_job_id, open(jsonpath, "w"))

    load_slices(force=force)
#------------------------------
#Print statistics
#------------------------------
def print_statistics(l_job):
    for job in l_job:
        if type(job) == int:
            job = jobs(job)
        elif type(job) == str:
            job = jobs(int(job))

        print("----------------")
        print_job_statistics(job)
        print("----------------")
#------------------------------
def resubmit_job(job, evtThreshold=10, printInputFile=False ):
    import glob, re, os.path

    logfile = 'Script1_Ganga_GaudiExec.log'
    total = 0
    processedEvt = 0
    subjoblist=[]
    failedlist=[]
    submitlist=[]

    p=re.compile(r'SUCCESS (\d{1,8}) events processed')
    print(40*"=")
    print("Checking job:", job.id)
    print(40*"=")
    for js in job.subjobs:
        if js.status=='completed':
            fullname = os.path.join( js.outputdir, logfile )
            if os.path.isfile(fullname):
                f = map(int, p.findall(open(fullname).read()))
                try:
                    processedEvt = list(f).pop()
                    if processedEvt < evtThreshold:
                        subjoblist.append(js.id)
                        print(" * {0} events processed: {1} {2} {3}".format(processedEvt, job.id, js.id, js.backend.id) )
                        if printINputFile:
                            for i in js.inputdata.files:
                                print(i.name)
                    else:
                        total = total + processedEvt
                except:
                    print("Not finalized subjob: {0}.{1} {2}".format(job.id, js.id, js.backend.id) )
                    subjoblist.append(js.id)
            else:
                print("File {0} not exist for subjob {1}".format(logfile, js.id) )
                subjoblist.append(js.id)
                
    return total

    print('Already processed events:', total)
    print('#Not finalized subjobs:', len(subjoblist) )
    
    if subjoblist:
        answer = input( 'Would you like to resubmit not finalized job? (y/n)' )
        if answer == 'Y' or answer == 'y' or answer == 'Yes' or answer == 'yes':
            for s in subjoblist:
                job.subjobs[s].resubmit()
                #job.subjobs[s].backend.getOutputSandbox()
    
    # resubmit failed subjobs
    for js in job.subjobs:
        if js.status=='failed':
            print('Failed subjob: {0} {1}'.format(js.id, js.backend.id) )
            failedlist.append(js.id)
    print('#Failed subjobs:', len(failedlist))
    
    if failedlist: 
        reFailed = input( 'Would you like to resubmit failed job? (y/n)' )
        if reFailed == 'Y' or reFailed == 'y' or reFailed == 'Yes' or reFailed == 'yes':
            for s in failedlist:
                job.subjobs[s].resubmit()
    
    # resubmit submitting subjobs:
    for js in job.subjobs:
        if js.status=='submitting':
            print('Submitting subjob:', js.id)
            submitlist.append(js.id)
    print('#Failed subjobs:', len(submitlist))

    if submitlist: 
        reFailed = input( 'Would you like to resubmit the submitting job? (y/n)' )
        if reFailed == 'Y' or reFailed == 'y' or reFailed == 'Yes' or reFailed == 'yes':
            for s in submitlist:
                job.subjobs[s].force_status('failed')
                job.subjobs[s].resubmit()

    return total
#------------------------------
def resubmit_jobs(slc, latex_path=None):
    d_stats = {}
    for job in slc:
        nevt = resubmit_job(job)
        d_stats[job.id] = [job.id, nevt]

    if latex_path is not None:
        utnr.save_to_latex(d_stats, latex_path, indices=['Job ID', 'Processed'])
#------------------------------
def print_job_statistics(job):
    print("Job #{}".format(job.id))

    data=job.inputdata
    try:
        d_mt=data.bkMetadata()
    except:
        print("print_job_statistics::Cannot find bookkeeping metadata for job {}".format(job.id))
        return

    d_lfn_nev={}
    total=0.
    for LFN, d_data in d_mt['Successful'].items():
        if "EventStat" not in d_data:
            keys=str(d_data.keys())
            print("EventStat not found in " + keys)
            continue

        nevents=d_data['EventStat']
        d_lfn_nev[LFN] = nevents
        total+=nevents

    l_sjob=job.subjobs
    l_lfn=[]
    for sjob in l_sjob:
        if sjob.status == 'failed':
            data=sjob.inputdata
            l_lfn+=data.getLFNs()

    missing=0.
    for lfn in l_lfn:
        missing+=d_lfn_nev[lfn]

    print("Missing {}/{} = {:.2f}%".format(missing, total, 100 * missing/total))
#------------------------------
def get_log_events(obj, stored = False):
    '''
    Used to get number of events processed and optionally stored in ntuples with:
    ```python
    get_log_events(job, stored=True)

    ```
    Parameters:
    -------------------------
    job : Ganga job with subjobs or subjob or job id, list of jobs or slice
    stored (bool): Should count also stored events in ntuples?
    '''
    l_job = get_jobs(obj)
    l_dat = []

    nproces=0
    nstored=0
    for job in tqdm(l_job, ascii=' -'):
        if stored:
            proc, stor, date = get_log_events_job(job, stored=stored)
            nproces += proc
            nstored += stor
        else:
            proc,       date = get_log_events_job(job, stored=stored)
            nproces += proc

        l_dat.append(date)

    return nproces, nstored, l_dat
#------------------------------
def get_log_events_job(job, stored=False):
    if   job.status != 'completed' and     stored:
        return 0, 0, 'na'
    elif job.status != 'completed' and not stored:
        return 0, 'na'

    l_log = glob.glob(job.outputdir + "/*.log")
    if len(l_log) != 1:
        print("Could not find one and only one log file in " + job.outputdir)
        return (-1, 'na') if not stored else (-1, -1, 'na')

    filename = l_log[0]
    ifile=open(filename)
    try:
        l_line=ifile.read().splitlines()
    except:
        print('Cannot read ' + filename)
        ifile.close()
        if stored:
            return -1, -1, 'na'
        else:
            return -1, 'na'

    ifile.close()

    date = os.path.getctime(filename)
    date = datetime.fromtimestamp(date)
    date = date.strftime('%d.%m.%y')

    regex="[a-zA-Z\.\s]+\|[\d.\s]+\|[\d.\s]+\|[\d.\s]+\|([\d\s]+)\|[\d.\s]+\|"
    proc_stat = None 
    stor_stat = None 
    for i_line, line in enumerate(l_line):
        if "EVENT LOOP" in line:
            mtch=re.match(regex, line)
            val=mtch.group(1)
            proc_stat=int(val)
            if not stored:
                return proc_stat, date

        if 'Tree    :DecayTree : DecayTree' in line:
            stored_line = l_line[i_line + 1]
            str_stat = stored_line.split(':')[1]
            stor_stat = int(str_stat) 
            if stor_stat == 0:
                print('Found no stored events in:')
                print(stored_line)
                raise

        if (proc_stat is not None) and (stor_stat is not None):
            return proc_stat, stor_stat, date

    #print(f'Could not find stats in file {filename}, job id {job.id}')

    return (-1, date) if not stored else -1, -1, date
#------------------------------
def get_jobs(obj):
    if type(obj) == int:
        obj = jobs(obj)

    l_job=[]
    if   type(obj) == type(jobs.select(0,0)):
        for job in obj:
            l_job+=get_jobs(job)
    elif type(obj) == Job and len(obj.subjobs) != 0:
        l_job=obj.subjobs
    elif type(obj) == Job and len(obj.subjobs) == 0:
        l_job=[obj]
    elif type(obj) == list:
        l_job = obj
    else:
        print("Cannot recognize object of type " + str(type(obj)))
        raise

    return l_job
#------------------------------
def printFailedInfo(sl_job):
    d_site={}
    d_info={}
    failed=0
    total=0

    l_job = get_jobs(sl_job)
    for job in l_job:
        total+=1
        if job.status == 'failed':
            failed+=1
            site=job.backend.actualCE
            info=job.backend.extraInfo
            if site not in d_site:
                d_site[site] = 1
            else:
                d_site[site]+= 1

            if info not in d_info:
                d_info[info] = 1
            else:
                d_info[info]+= 1

    print("-----------------")
    print("------SITE-------")
    print("-----------------")
    for site, freq in d_site.items():
        print("{0:100}{1:10}".format(site, freq))

    print("-----------------")
    print("------INFO-------")
    print("-----------------")
    for info, freq in d_info.items():
        print("{0:100}{1:10}".format(info, freq))

    print("-----------------")
    print("Failed/Total: {}/{}".format(failed, total))
    print("-----------------")
#------------------------------
def printIDName(sl_job, verbose=False):
    l_id_name=[]
    for job in sl_job:
        ID=job.id
        name=job.name
        l_id_name.append((ID, name))

    l_id_name=sorted(l_id_name, key=lambda x: x[1])

    if verbose:
        for ID, name in l_id_name:
            print("{0:<20}{1:<50}".format(ID, name))

    pickle.dump(l_id_name, open("id_name.pickle", "wb"))
#------------------------------
#Remove jobs
#------------------------------
def remove_jobs(l_job, lapse=10):
    print("Will start removing jobs in {} seconds".format(lapse))
    time.sleep(lapse)

    for job in l_job:
        job.remove()
#------------------------------
#Fix status for completed
#------------------------------
def fix_completed(l_job):
    for job in l_job:
        l_sjob=job.subjobs
        for sjob in l_sjob:
            try:
                lfn=sjob.outputfiles[0].lfn
                if lfn != "" and sjob.status != 'completed':
                    sjob.force_status('completed')
            except:
                continue
#------------------------------
#Kill
#------------------------------
def kill_unfinished(l_job):
    for job in l_job:
        if type(job) == int:
            job=jobs(job)

        l_sjob=job.subjobs
        for sjob in l_sjob:
            if sjob.status != "completed" and sjob.status != "failed":
                sjob.force_status('failed')
#------------------------------
def fail_list(l_job, filepath):
    ifile=open(filepath)
    l_ID=ifile.read().splitlines()
    ifile.close()

    for job in l_job:
        l_sj=job.subjobs
        for sj in l_sj:
            ID=sj.backend.id
            if str(ID) in l_ID:
                #print("Failing {}-{}".format(job.id, sj.id))
                sj.force_status('failed')
#------------------------------
#Monitoring
#------------------------------
def monitor(sl_job):
    global do_monitor
    do_monitor=True

    if   type(sl_job) == str:
        sl_job=get_slice(sl_job)
    elif type(sl_job) == int:
        sl_job=jobs.select(sl_job, sl_job)

    queues.add(monitor_loop, args=(sl_job,))

    return sl_job
#------------------------------
def keep_monitoring():
    if do_monitor:
        return True
    else:
        print("Monitoring has been stopped")
        return False
#------------------------------
def monitor_loop(sl_job):
    while keep_monitoring():
        l_queue=queues.threadStatus()
        if len(l_queue) > 1:
            time.sleep(60)
            continue
        else:
            if not hasStatus(sl_job, "submitted") and not hasStatus(sl_job, "running"):
                print("No job needs monitoring, finishing loop")
                return

            print("Reruning monitoring")
            runMonitoring(sl_job)

        time.sleep(60)
#------------------------------
def hasStatus(sl_job, status):
    display(sl_job)
    for job in sl_job:
        if job.status == status:
            return True

    return False
#------------------------------
def check_status(JOBID):
    j=jobs(JOBID)
    l_sj=j.subjobs
    d_job=dict()
    for sj in l_sj:
        status=sj.status
        if status not in d_job:
            d_job[status]=1
        else:
            d_job[status]+=1

    for status in d_job:
        njobs=d_job[status]
        print("{0:20}{1:20}".format(status, njobs))
#------------------------------
def reset_backend(JOBID, state='submitted'):
    j=jobs(JOBID)
    l_job=list()
    for job in j.subjobs:
        status=job.status
        ID=job.id
        if state == 'all':
            job.backend.reset()
            print("Resetting job {}".format(ID))
        elif state == status:
            job.backend.reset()
            print("Resetting job {}".format(ID))
#------------------------------
#Re-submit
#------------------------------
def resubmit_failed_jobs(l_job, HOURS=10, SWITCH_CE=False):
    if type(l_job) == str:
        l_job=get_slice(l_job)

    for job in l_job:
        if type(job) == int:
            job=jobs(job)
        resubmit_failed(job, HOURS=HOURS, SWITCH_CE=SWITCH_CE)
#------------------------------
def resubmit_failed(j, HOURS=10, SUBJOB=-1, SWITCH_CE=False):
    submitted=0
    total=0

    if   len(j.subjobs) == 0 and j.status == 'failed':
        l_job=[j]
    elif len(j.subjobs) == 0 and j.status != 'failed':
        return
    elif len(j.subjobs) >  0: 
        l_job=j.subjobs.select(status='failed')

    for job in l_job:
        ID=job.id
        if SUBJOB != -1 and ID != SUBJOB:
            continue

        if SWITCH_CE:
            CE=job.backend.actualCE
            job.backend.settings['BannedSites']=CE

        #From https://groups.cern.ch/group/lhcb-distributed-analysis/Lists/Archive/Flat.aspx?RootFolder=%2Fgroup%2Flhcb%2Ddistributed%2Danalysis%2FLists%2FArchive%2FJobs%20do%20not%20run%207878&FolderCTID=0x01200200AD716970E9BBD0488B2362305E8E167D
        d_settings=job.backend.settings
        d_settings['CPUTime'] = 3600 * HOURS * 15

        print("Running with CPUTime: {}".format(d_settings['CPUTime']))
        total+=1
        try:
            job.resubmit()
        except:
            print("Failed!!!")
            continue

        print("Resubmitting {}".format(ID))
        submitted+=1

    print("Submitted {}/{} jobs".format(submitted, total))
#------------------------------
def resubmit_running(JOBID):
    j=jobs(JOBID)
    njobs=0
    for job in j.subjobs.select(status='running'):
        ID=job.id
        job.force_status('failed')
        job.resubmit()
        print("Resubmitting {}".format(ID))
        njobs+=1

    print("Submitted {} jobs".format(njobs))
#------------------------------
def force_to_failed(JOBID, status):
    j=jobs(JOBID)
    l_sj=j.subjobs
    for sj in l_sj:
        stat=sj.status
        if stat != status:
            continue
        sj.force_status('failed')
#------------------------------
def extractID(job):
    regex="(\d+)\.\d+\.\d"

    mtch=re.match(regex, job.name)
    if mtch:
        ID=int(mtch.group(1))
    else:
        ID=job.id

    return ID
#------------------------------
def write_xfns(l_job, kind, dirpath = '.', prefix='job'):
    if kind not in ['lfn', 'pfn']:
        print('Invalid kind: ' + kind)
        raise

    if type(l_job) == str:
        l_job = get_slice(l_job)

    d_xfn=dict()
    for job in l_job:
        jobid=extractID(job)
        print('Job: {:05}'.format(jobid))

        l_sj = job.subjobs
        if len(l_sj) == 0:
            l_sj = [job]
            
        for sj in tqdm(l_sj):
            if sj.status != 'completed':
                ident = '{}.{}'.format(jobid, sj.id)
                print('{0:<20}{1:<20}'.format('ID'    ,     ident))
                print('{0:<20}{1:<20}'.format('Status', sj.status))
                continue

            l_file=sj.outputfiles.get(DiracFile)
            if len(l_file) == 0:
                print("----------------------------")
                print("Cannot find files for job #{}".format(sj.id))
                print(sj.outputfiles)
                print("----------------------------")
                continue

            for df in l_file:
                if   kind == 'lfn':
                    l_xfn=[df.lfn]
                elif kind == 'pfn':
                    try:
                        l_xfn=df.accessURL()
                    except:
                        print('Cannot retrieve URL for: {}'.format(df.lfn))
                        continue

                for xfn in l_xfn:
                    xfn=xfn.replace(' ', '')

                    if xfn == '':
                        print("Could not find {} for {}.{}".format(kind, job.id, sj.id))
                        continue

                    if jobid not in d_xfn:
                        d_xfn[jobid]=[xfn]
                    else:
                        d_xfn[jobid].append(xfn)

    for jobid in d_xfn:
        filename="{}/{}_{}.{}".format(dirpath, prefix, jobid, kind)
        print("Sending xFNs to: " + filename)
        l_xfn=d_xfn[jobid]
        if len(l_xfn) == 0:
            print("Could not find {}s for job {}".format(kind, jobid))
            continue

        f=open(filename, "w")
        for xfn in l_xfn:
            f.write("{}\n".format(xfn))
        f.close()
#----------------------------------
def remove_new_jobs(MAXID):
    for ID in range(0, MAXID + 1):
        try:
            j=jobs(ID)
            if j.status == 'new':
                print("Removing job {}".format(ID))
                #j.remove()
        except:
            print("Cannot retrieve job {}".format(ID))
#------------------------------
def reset_all_backends(l_JOBID, flag=False):
    for ID in l_JOBID: 
        j=jobs(ID)
        status = j.status
        if status == "new":
            try:
                j.backend.reset(flag)
                print("Resetting #{}".format(ID))
            except:
                print("Cannot reset #{}".format(ID))
#------------------------------
def run_monitoring(l_JOBID):
    for JOBID in l_JOBID:
        print("Running monitoring for job #{}".format(JOBID))
        runMonitoring(jobs.select(id=JOBID))
#------------------------------
def send_empty():
    j=Job()
    j.name   = "test"
    j.backend= Dirac()
    j.submit()
#------------------------------
def download_output(ID):
    j=jobs(ID)
    for sj in j.subjobs:
        sj.backend.getOutputSandbox()
#------------------------------
#Getting LFNs
#------------------------------
def write_std_lfn(l_sjob, out_name = 'output.lfn'):
    """
    Writes to text file list of LFNs from std.out file
    The input is a list of subjobs
    """

    l_lfn = []
    for sjob in l_sjob:
        l_lfn += get_std_job_lfn(sjob)
    l_lfn.sort()

    ofile=open(out_name, 'w')
    for lfn in set(l_lfn):
        ofile.write(lfn + '\n')
    ofile.close()
#------------------------------
def get_std_job_lfn(job):
    std_path = f'{job.outputdir}/std.out'
    if not os.path.isfile(std_path):
        print(f'Not found: {std_path}')
        return []

    l_lfn=[]
    regex='.*\(\'(\/lhcb[\w.\/_]+.root)\',\'.*'
    with open(std_path) as ifile:
        l_line = ifile.readlines()
        for line in l_line:
            if 'Attempting dm.putAndRegister' not in line:
                continue
        
            mtch = re.match(regex, line)
            if not mtch:
                log.error(f'Could not extract LFN from "{line}"')
                raise
        
            lfn = mtch.group(1)
            l_lfn.append(lfn)

    l_lfn.sort()

    return l_lfn
#------------------------------

