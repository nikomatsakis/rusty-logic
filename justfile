build:
    cd doc && make html

serve: build
    python3 -m http.server --directory doc/_build/html
