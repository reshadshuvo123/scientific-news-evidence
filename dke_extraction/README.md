# 🏷️ Domain Knowledge Entity Extraction

> **Paper:** J. Wu, M. R. U. Hoque, G. W. Reiske, M. C. Weigle, B. T. Bradshaw, H. D. Gaff, J. Li, C. Kwan.
> *A Comparative Study of Sequence Tagging Methods for Domain Knowledge Entity Recognition in Biomedical Papers.*
> [JCDL 2020, pp. 397–400](https://dblp.org/rec/conf/jcdl/WuHRWBGLK20)

## What this module does

A **domain knowledge entity (DKE)** is a noun phrase that carries domain-specific meaning — *symbiotic binary system*, *CRISPR-Cas9*, *photocatalytic degradation*. DKEs differ from generic named entities (people, places, dates) and from statistical keyphrases: understanding them takes some domain knowledge, and crucially they tend to appear **verbatim in both a news article and the paper it reports on**, even when everything around them has been paraphrased.

That property is what makes them good retrieval queries. This module turns DKE extraction into a BIO sequence-tagging problem and compares nine architectures on it.

```
Input :  "AG Draconis is a strongly interacting binary system ..."
Output:  [AG Draconis]DKE is a strongly interacting [binary system]DKE ...
```

## Models implemented

| Model | File | Idea |
|---|---|---|
| BiLSTM-CRF | `BiLSTM-CRF.py` | Word-level BiLSTM encoder, CRF decoding layer. Standard NER baseline. |
| LSTM-CRF | `LSTM-CRF-DKE.py` | Unidirectional variant, for ablation. |
| Residual BiLSTM | `Residual-BiLSTM.py` | Two stacked BiLSTMs with a residual connection between them. |
| BiLSTM + character embeddings | `BiLSTM-CharacterE.py` | Character-level BiLSTM concatenated with word-level encoding — captures morphology and handles out-of-vocabulary technical terms. |
| ELMo-BiLSTM | `Elmo-BiLSTM.py` | BiLSTM initialized with pre-trained contextual ELMo embeddings. |
| ELMo-BiLSTM + attention | `ELmo-BiLSTM-Attention.py` | Adds a self-attention layer over the combined encoding. |
| Transformer (from scratch) | `transformer1.py` | Trained on the annotated corpus only, no pre-training. |
| BERT / RoBERTa fine-tuned | `bert_roberta_bio_tagging.py` | Pre-trained encoder fine-tuned for BIO tagging. **Best performer.** |
| BERT / RoBERTa multi-domain | `bert_roberta_multidomain.py` | Fine-tuned across all ten OA-STM domains jointly. |
| Linear-chain CRF | `crf_baseline.py`, `crf_enhanced.py` | Feature-engineered CRF with lexical and morphological features. Non-neural baseline. |

Supporting files:

- `PhraseEval.py` — phrase-level (not token-level) precision/recall/F1, which is the metric that actually matters for retrieval
- `bert_roberta_testing.py` — inference and evaluation on held-out domains
- `models/` — pickled trained linear-chain CRF models

## Results

The fine-tuned BERT tagger essentially saturates the task, reaching **F1 between 0.92 and 1.00** across all ten OA-STM domains — perfect extraction on mathematics. Models trained from scratch fall well short: the best of them, ELMo-BiLSTM, reaches roughly **F1 = 0.51–0.54** on materials science, biology and chemistry.

The size of that gap is the interesting part. With only ~5,600 annotated entities to learn from, architecture choice matters far less than whether the encoder arrived pre-trained. Adding self-attention to the character-embedding model helped on agriculture, engineering, mathematics and biology but hurt on other domains — a wash, and a reminder that on small corpora these deltas are within noise.

## Data

| File | Contents |
|---|---|
| `data/train_comall.txt` | Combined multi-domain training set, CoNLL format |
| `data/test_com1.txt` | Held-out test set |

Sources:

- **SemEval-2017 Task 10 (ScienceIE)** — 500 passages from Computer Science, Materials Science and Physics papers; >7,000 annotated entities across MATERIAL, METHOD and PROCESS. Used for pre-training.
- **[OA-STM](https://github.com/elsevierlabs/OA-STM-Corpus)** — 11 abstracts each from 10 domains (agriculture, astronomy, biology, chemistry, computer science, earth science, engineering, materials science, mathematics, medicine); 5,595 annotated entities across PROCESS, METHOD, MATERIAL and DATA. Used for fine-tuning.

All entity categories are collapsed into a single `DKE` class, since downstream retrieval does not care which type an entity is.

## Running it

```bash
# Fine-tune the transformer tagger (recommended)
python bert_roberta_bio_tagging.py

# Neural baselines
python BiLSTM-CRF.py
python Elmo-BiLSTM.py

# Non-neural baseline
python crf_baseline.py
```

Data files are expected in `data/`. Train/test paths are set at the top of each script — adjust them there.

Evaluate at phrase level:

```bash
python PhraseEval.py --pred predictions.txt --gold data/test_com1.txt
```
