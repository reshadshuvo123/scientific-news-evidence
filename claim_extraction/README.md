# 📌 ClaimDistiller — Scientific Claim Extraction

> **Paper:** X. Wei, M. R. U. Hoque, J. Wu, J. Li. *ClaimDistiller: Scientific Claim Extraction with Supervised Contrastive Learning.*
> [Joint Workshop of EEKE2023 and AII2023 @ JCDL 2023, pp. 65–77](https://dblp.org/rec/conf/eeke/WeiH0023)

## What this module does

Retrieving the right paper is only half of verifying a news article. The other half is comparing what the article asserts against what the paper actually claims — and for that you first need to know which sentences in the paper *are* claims.

This module frames that as binary sentence classification over scientific abstracts.

```
"We recruited 240 participants across three sites."        → not a claim (method)
"Germline RBP roles are thus highly context-dependent."    → claim
```

Two ideas drive the approach:

**Supervised contrastive learning.** Instead of training only against a cross-entropy objective, the model is also pushed to pull claim sentences together in embedding space and push non-claims away. Claims and methods sentences are often lexically similar and differ mainly in rhetorical function, which is exactly the situation where a contrastive objective helps.

**Transfer learning.** The annotated claim corpus is small (1,500 abstracts). Pre-training on a larger discourse-annotated dataset before fine-tuning transfers the general notion of rhetorical role, so the model is not learning it from scratch.

## Models implemented

Each architecture appears in four variants, which makes the two contributions independently measurable: **base**, **+ contrastive**, **+ transfer**, and both.

| Encoder | Base | Contrastive | Transfer |
|---|---|---|---|
| 1D CNN | `1D-CNN.py` | `1D-CNN-Contrastive.py` | `1D-CNN-transfer.py`, `1D-CNN-Contrastive-transfer.py` |
| Universal Sentence Encoder | `USE-Dense.py` | `USE-Contrastive.py` | `USE-Dense-Transfer.py` |
| Word-Character LSTM | `WC-LSTM.py` | `WC-LSTM-contrastive.py` | `WC-LSTM-transfer.py` |
| BERT | `Bert-Dense.ipynb` | — | `Bert-transfer-Dense.ipynb` |

`helper_functions.py` holds shared preprocessing, batching and evaluation code.

## Data

`data/` contains the train / validation / test label splits as JSON.

The underlying corpus is **1,500 biomedical abstracts** with sentence-level claim annotations. Three annotators with biomedical background and English fluency labelled each sentence independently; the released labels are the majority vote. The corpus comes from [titipata/detecting-scientific-claim](https://github.com/titipata/detecting-scientific-claim) — see that repository for the abstract text, licensing and annotation protocol.

| File | Split |
|---|---|
| `data/train_labels.json` | Training |
| `data/validation_labels.json` | Validation |
| `data/test_labels.json` | Test |

## Running it

```bash
# Best setting: contrastive + transfer
python codes/1D-CNN-Contrastive-transfer.py

# Ablations
python codes/1D-CNN.py                 # neither
python codes/1D-CNN-Contrastive.py     # contrastive only
python codes/1D-CNN-transfer.py        # transfer only
```

For the BERT variants, open `codes/Bert-Dense.ipynb` or `codes/Bert-transfer-Dense.ipynb`.

Fetch the abstract text from the upstream repository and place it alongside the label files in `data/` before running.

## Results

Reported metrics are precision, recall and F1 on claim sentences. See the paper for the full comparison across encoders and variants.

<!-- TODO: paste the headline F1 numbers from Table 2 of the paper here — a small
     table showing base vs. +contrastive vs. +transfer for each encoder makes
     the two contributions immediately legible to anyone skimming the repo. -->
