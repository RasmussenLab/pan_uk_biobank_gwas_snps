"""
Filter all GWAS from Pan GWAS project on uk biobank.
"""

from pathlib import Path, PurePosixPath


configfile: "config/all_gwas.yaml"


url_template = (
    "https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/{file}.tsv.bgz"
)

folder_gwas_downloaded = "data/gwas_downloaded"
folder_gwas_filtered = "data/gwas_filtered"
files = config["urls"]
names = config["names"]



rule all:
    input:
        "combined_gwas.csv",


rule combine_gwas:
    input:
        filtered_gwas=expand(folder_gwas_filtered + "/{file}.csv", file=names),
    output:
        out="combined_gwas.csv",
    run:
        from pathlib import Path
        import pandas as pd
        import os
        #input.filtered_gwas = input.filtered_gwas.replace("\\|", "|")
        print(repr(input.filtered_gwas))
        folder_duplicated = Path("data/gwas_duplicated")
        folder_duplicated.mkdir(exist_ok=True)

        df = list()

        for fname in input.filtered_gwas:
            if os.path.getsize(fname) > 1:
                _df = pd.read_csv(fname, index_col=[0, 1]).astype("float16")
                if not _df.empty:
                    col_name = Path(fname).stem
                    if not _df.index.is_unique:
                        non_unique = _df.index[_df.index.duplicated(keep=False)]
                        print("*" * 5 + f"name: {col_name}" + "*" * 5)
                        print(f"non-unique index: {non_unique}")
                        # display(_df.loc[non_unique])
                        fname_duplicated = folder_duplicated / f"{col_name}.non_unique.csv"
                        print(f"Saving duplicated rows to: {fname_duplicated}")
                        _df.loc[non_unique].to_csv(fname_duplicated)
                        _df = _df.loc[~_df.index.duplicated(keep="first")]
                    col_name = Path(fname).stem
                    if 'neglog10_pval_meta_hq' in _df.columns:
                        df.append(_df["neglog10_pval_meta_hq"].rename(col_name))
                    elif 'neglog10_pval_meta' in _df.columns:
                        df.append(_df["neglog10_pval_meta"].rename(col_name))
                else:
                    print(f"empty file: {fname}")
        df = pd.concat(df, axis=1)
        print(f"Shape of {output.out}: {df.shape}")
        df.to_csv(output.out)


rule filter_gwas:
    input:
        fname_in=folder_gwas_downloaded + "/{file}.tsv.bgz",
    output:
        fname_out=folder_gwas_filtered + "/{file}.csv",
    run:
        import pandas as pd
        
        column_names = pd.read_csv(
            input.fname_in, 
            compression="gzip", 
            sep="\t", 
            nrows=0).columns.tolist()

        if 'neglog10_pval_meta_hq' in column_names:
            iter_csv = pd.read_csv(
                    input.fname_in,
                    header=0,
                    compression="gzip",
                    sep="\t",
                    usecols=
                        ("chr",
                                "pos",
                                "beta_meta_hq",
                                "se_meta_hq",
                                "neglog10_pval_meta_hq"
                            ),
                            iterator=True,
                            chunksize=10_000,
                        )
            p_value_column = "neglog10_pval_meta_hq"
            
            df = pd.concat(
                [chunk.dropna().query(f'{p_value_column} > 16') for chunk in iter_csv]
            )
            
        elif 'neglog10_pval_meta' in column_names:
            iter_csv = pd.read_csv(
                    input.fname_in,
                    header=0,
                    compression="gzip",
                    sep="\t",
                    usecols=
                        ("chr",
                                "pos",
                                "beta_meta",
                                "se_meta",
                                "neglog10_pval_meta"
                            ),
                            iterator=True,
                            chunksize=10_000,
                        )
            p_value_column = "neglog10_pval_meta"
            
            df = pd.concat(
                [chunk.dropna().query(f'{p_value_column} > 16') for chunk in iter_csv]
            )
            
        else:
            df = pd.DataFrame()
        df.to_csv(output.fname_out, index=False)


rule download:
    output:
        local=temp(folder_gwas_downloaded + "/{file}.tsv.bgz"),
    params:
        ftp_location=url_template,
    threads: 1
    retries: 2
    shell:
        """
        f=$(echo "{params.ftp_location}")
        out=$(echo "{output.local}")
        escaped_url=$(echo $f | sed -e 's/|/%7C/g')
        wget -nv $escaped_url -O $out
        """
