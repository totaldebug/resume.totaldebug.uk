# resume-priv — Steven Marks resume (private source)

Private Jekyll source for the resume site published at
[https://resume.totaldebug.uk](https://resume.totaldebug.uk).

## How it publishes

This repo holds the source. On every push to `main`, the
[`Build and deploy resume`](.github/workflows/deploy.yml) workflow:

1. Builds the site with Jekyll.
2. Renders `print.html` to `Steven-Marks-Resume.pdf` via headless Chrome.
3. Publishes the rendered `_site` to the **public**
   [`totaldebug/resume.totaldebug.uk`](https://github.com/totaldebug/resume.totaldebug.uk)
   repo (`gh-pages` branch) using [`peaceiris/actions-gh-pages`](https://github.com/peaceiris/actions-gh-pages).

GitHub Pages serves the `gh-pages` branch of the public repo at the custom
domain `resume.totaldebug.uk`.

```
resume-priv (private)  ──build──▶  resume.totaldebug.uk (public, gh-pages)  ──▶  https://resume.totaldebug.uk
```

Publishing is authenticated with an SSH deploy key: the private key is stored
as the `DEPLOY_KEY` Actions secret in this repo, and the matching public key is
registered as a read/write deploy key on the public output repo.

## Local preview

Install Ruby and Bundler, then:

```sh
bundle install
bundle exec jekyll serve
```
