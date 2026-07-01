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

## Setup

How this private-source → public-output split was wired up, in case it ever
needs rebuilding (requires the `gh` CLI, authenticated with an account that
administers both repos):

1. **Create this private source repo** and push the Jekyll source to `main`:

   ```sh
   gh repo create totaldebug/resume-priv --private
   git remote add origin git@github.com:totaldebug/resume-priv.git
   git push -u origin main
   ```

2. **Generate an SSH deploy keypair** (no passphrase):

   ```sh
   ssh-keygen -t ed25519 -N "" -C "resume-priv-deploy" -f resume_deploy_key
   ```

3. **Register the public key** as a read/write deploy key on the public output
   repo, so CI can push the rendered site:

   ```sh
   gh repo deploy-key add resume_deploy_key.pub \
     --title "resume-priv CI deploy" --allow-write \
     -R totaldebug/resume.totaldebug.uk
   ```

4. **Store the private key** as the `DEPLOY_KEY` Actions secret in this repo,
   then delete the local key files:

   ```sh
   gh secret set DEPLOY_KEY -R totaldebug/resume-priv < resume_deploy_key
   rm resume_deploy_key resume_deploy_key.pub
   ```

5. **Point GitHub Pages** on the public repo at the `gh-pages` branch (the
   branch is created by the first successful deploy run):

   ```sh
   gh api -X PUT repos/totaldebug/resume.totaldebug.uk/pages \
     -f "build_type=legacy" \
     -f "source[branch]=gh-pages" -f "source[path]=/"
   ```

   The custom domain (`resume.totaldebug.uk`) is written to the `gh-pages`
   branch as a `CNAME` file by the `cname:` option in the deploy workflow.

## Local preview

Install Ruby and Bundler, then:

```sh
bundle install
bundle exec jekyll serve
```
