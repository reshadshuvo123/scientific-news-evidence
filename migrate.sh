#!/usr/bin/env bash
# Copies the code from the original Fake_scientic_news_detections repo into
# this layout, renaming files to descriptive names.
#
#   ./migrate.sh /path/to/Fake_scientic_news_detections
#
# Safe to re-run. Nothing is deleted from the source.

set -euo pipefail
SRC="${1:?usage: ./migrate.sh /path/to/Fake_scientic_news_detections}"
DST="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$DST"/dke_extraction/{data,models,notebooks} \
         "$DST"/evidence_retrieval \
         "$DST"/claim_extraction/{codes,data} \
         "$DST"/demo

cp_if() { [ -f "$1" ] && cp "$1" "$2" || echo "  skip (missing): $1"; }

echo "→ DKE extraction"
for f in BiLSTM-CRF.py BiLSTM-CharacterE.py ELmo-BiLSTM-Attention.py \
         Elmo-BiLSTM.py LSTM-CRF-DKE.py Residual-BiLSTM.py \
         PhraseEval.py transformer1.py; do
  cp_if "$SRC/DKEs/$f" "$DST/dke_extraction/$f"
done
cp_if "$SRC/DKEs/ber-robarta-code-bio-tagging.py"    "$DST/dke_extraction/bert_roberta_bio_tagging.py"
cp_if "$SRC/DKEs/ber-robarta-code-multidomain-fi.py" "$DST/dke_extraction/bert_roberta_multidomain.py"
cp_if "$SRC/DKEs/ber-roberta-testing.py"             "$DST/dke_extraction/bert_roberta_testing.py"
cp_if "$SRC/DKEs/crf-model-run.py.txt"               "$DST/dke_extraction/crf_baseline.py"
cp_if "$SRC/DKEs/crf-enhance.py"                     "$DST/dke_extraction/crf_enhanced.py"
cp_if "$SRC/DKEs/train_comall.txt"                   "$DST/dke_extraction/data/train_comall.txt"
cp_if "$SRC/DKEs/test_com1.txt"                      "$DST/dke_extraction/data/test_com1.txt"
cp "$SRC"/DKEs/*.pickle  "$DST/dke_extraction/models/"    2>/dev/null || true
cp "$SRC"/DKEs/*.ipynb   "$DST/dke_extraction/notebooks/" 2>/dev/null || true

echo "→ Evidence retrieval (SciEv)"
cp_if "$SRC/SciPEP/FSND-tfidf.py"                 "$DST/evidence_retrieval/rank_tfidf.py"
cp_if "$SRC/SciPEP/FSND-w2v.py"                   "$DST/evidence_retrieval/rank_word2vec.py"
cp_if "$SRC/SciPEP/FSND-document-embedding.py"    "$DST/evidence_retrieval/rank_doc2vec.py"
cp_if "$SRC/SciPEP/FSND-doc2vec-tfidf.py"         "$DST/evidence_retrieval/rank_doc2vec_tfidf.py"
cp_if "$SRC/SciPEP/FSND-scibert.py"               "$DST/evidence_retrieval/rank_scibert.py"
cp_if "$SRC/SciPEP/FSND-BOC-scibert.py"           "$DST/evidence_retrieval/rank_scibert_boc.py"
cp_if "$SRC/SciPEP/FSND-sbert.py"                 "$DST/evidence_retrieval/rank_sbert.py"
cp_if "$SRC/SciPEP/FSND-specter.py"               "$DST/evidence_retrieval/rank_specter.py"
cp_if "$SRC/SciPEP/DKE-textrank-base1.py"         "$DST/evidence_retrieval/rank_textrank_baseline.py"
cp_if "$SRC/SciPEP/experiment-undke-baseline-3.py" "$DST/evidence_retrieval/rank_no_dke_baseline.py"
cp_if "$SRC/SciPEP/matric.py"                     "$DST/evidence_retrieval/metrics.py"

echo "→ Claim extraction (ClaimDistiller)"
cp "$SRC"/Claim_Extraction/codes/*.py    "$DST/claim_extraction/codes/" 2>/dev/null || true
cp "$SRC"/Claim_Extraction/codes/*.ipynb "$DST/claim_extraction/codes/" 2>/dev/null || true
cp "$SRC"/Claim_Extraction/data/*.json   "$DST/claim_extraction/data/"  2>/dev/null || true
rm -f "$DST/claim_extraction/codes/Untitled14.ipynb"

echo "→ Demo"
cp_if "$SRC/Domain-Entities-extraction-given-links.py" "$DST/demo/extract_entities_from_url.py"

echo
echo "Done. Review, then:"
echo "  git init && git add . && git commit -m 'Reorganized: four-paper scientific news evidence pipeline'"
