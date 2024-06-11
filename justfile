build:
    pdflatex sn-article.tex
    # bibtex sn-article
    # pdflatex sn-article.tex
    # pdflatex sn-article.tex
    mdbook build
    mkdir -p book/assets
    cp sn-article.pdf book/assets

serve:
    cd book && python3 -m http.server
