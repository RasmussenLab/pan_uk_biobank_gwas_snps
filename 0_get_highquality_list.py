# %%
import yaml
import pandas as pd
from pathlib import Path
from tqdm.auto import tqdm

CFG_FNAME_OUT = Path('config/high_quality_gwas.yaml')
CFG_FNAME_OUT.parent.mkdir(exist_ok=True, parents=True)

# %%
url = ('https://docs.google.com/spreadsheets/d/'
       '1AeeADtT0U1AukliiNyiVzVRdLYPkTbruQSk38DeutU8'
       '/export?format=csv')
gwas_overview = pd.read_csv(url)

# %%
idx_in_max_indp_set = gwas_overview.loc[gwas_overview['in_max_independent_set']].index
idx_in_max_indp_set

# %%
gwas_hq = gwas_overview.query('n_cases_hq_cohort_both_sexes.notna()')

# %%
gwas_hq.loc[idx_in_max_indp_set].describe()

# %%
gwas_hq.describe(include='all')

# %%
url = 'https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/prescriptions-latanoprost-both_sexes.tsv.bgz'


def get_filename(url):
    return url.split('/')[-1].split('.')[0]


get_filename(url)

# %%
# %%
selected = gwas_hq.loc[idx_in_max_indp_set]
fname_to_url = {'urls': [get_filename(url) for url in selected['aws_link']]}

with open(CFG_FNAME_OUT, 'w') as f:
    yaml.dump(fname_to_url, f)
