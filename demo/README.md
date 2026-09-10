# ▶️ End-to-end demo

`extract_entities_from_url.py` runs the front half of the pipeline on a live news article: scrape → clean → extract DKEs → build arXiv queries.

```bash
python demo/extract_entities_from_url.py --url "https://www.sciencealert.com/some-article"
```

Steps performed:

1. Fetch the page and pull paragraph text out of the HTML
2. Strip bracketed references, collapse whitespace, remove special characters and digits
3. Sentence-split, tokenize and POS-tag
4. Tag domain knowledge entities with the trained CRF model
5. Print the extracted DKEs and the arXiv queries built from them

The parser targets ScienceAlert markup. Adapting it to another outlet means changing the paragraph selector near the top of the file — the rest of the pipeline is source-agnostic.

To rank the retrieved candidates, pass the output into one of the scripts in [`evidence_retrieval/`](../evidence_retrieval/).

> This script was written for Python 2 (`urllib2`). Port it to `requests` before running on a modern interpreter.
