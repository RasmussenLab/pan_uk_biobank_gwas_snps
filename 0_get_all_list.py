# %%
import yaml
import pandas as pd
from pathlib import Path
from tqdm.auto import tqdm

CFG_FNAME_OUT = Path('config/all_gwas.yaml')
CFG_FNAME_OUT.parent.mkdir(exist_ok=True, parents=True)

url = ('https://docs.google.com/spreadsheets/d/'
       '1AeeADtT0U1AukliiNyiVzVRdLYPkTbruQSk38DeutU8'
       '/export?format=csv')
gwas_overview = pd.read_csv(url)

all_set = gwas_overview.index
all_set

gwas_all = gwas_overview

gwas_all.describe()

gwas_all.describe(include='all')

url = 'https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/prescriptions-latanoprost-both_sexes.tsv.bgz'


def get_filename(url):
    x = url.split('/')[-1].split('.tsv')[0]
    #x = x.replace("|", "\\|")
    #y = ''.join(x)
    return x

def get_url(url):
    x = url.split('/')[-1].split('.tsv')[0]
    x = x.replace("|", "\\|")
    #y = ''.join(x)
    return x


get_filename(url)
selected = gwas_all
fname_to_url = {'urls': [get_url(url) for url in selected['aws_link']], 'names': [get_filename(url) for url in selected['aws_link']]}

with open(CFG_FNAME_OUT, 'w') as f:
    yaml.dump(fname_to_url, f)
